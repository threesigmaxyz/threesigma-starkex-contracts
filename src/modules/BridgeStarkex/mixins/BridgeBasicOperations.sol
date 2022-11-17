pragma solidity ^0.8.0;
pragma abicoder v2;

import "openzeppelin-contracts-upgradeable-master/contracts/security/PausableUpgradeable.sol";
import "openzeppelin-contracts-upgradeable-master/contracts/security/ReentrancyGuardUpgradeable.sol";

import "./BridgeCore.sol";
import "./SendAndRetrieveAssets.sol";
import "./LockedBalance.sol";

import "../libraries/ECDSA.sol";
import "../libraries/LibConstants.sol";
import "../libraries/StarkKeyVerifier.sol";
import "../libraries/TokenAssetData.sol";
import "../libraries/TokenRegister.sol";
import "../components/AvailabilityVerifiers.sol";
import "../components/Verifiers.sol";
import "../interfaces/LayerZero/ILayerZeroReceiver.sol";
import "../interfaces/LayerZero/ILayerZeroEndpoint.sol";
import "../libraries/BridgeUpdateState.sol";

import {PatriciaTree} from "../libraries/MPT.sol";

abstract contract BridgeBasicOperations is
ReentrancyGuardUpgradeable,
LockedBalance,
TokenAssetData,
Verifiers,
AvailabilityVerifiers,
TokenRegister,
PausableUpgradeable,
SendAndRetrieveAssets,
BridgeCore,
ILayerZeroReceiver
{

  // the LayerZero endpoint calls .send() to send a cross chain message
  ILayerZeroEndpoint public endpoint;

  // @notice Pending assets in the locks to deposit
  // @dev asset => amount
  mapping(address => uint256) public pendingDepositAssetSupply;

  // @notice Pending assets in the locks to withdraw
  // @dev asset => amount
  mapping(address => uint256) public pendingWithdrawAssetSupply;

  //Nonce to prevent replay attacks
  uint256 private nonce;

  //LayerZero variables
  mapping(address => uint) public remoteAddressCounter;
  uint public messageCounter;

  uint256 constant MASK_32 = 0xFFFFFFFF;
  uint256 constant MASK_64 = 0xFFFFFFFFFFFFFFFF;
  uint256 constant LIMIT_ORDER_TYPE = 0x3;


  /**
   * @notice Emitted when a user deposit is completed by a user
   * @dev The funds are transfered to the user wallet and the lock is cleared allowing
   * new withdraws.
   * @param receiver The address that will receive the funds
   * @param asset The asset id
   * @param amount The amount of funds that were transfered
   */
  event UserDeposit(address indexed receiver, address indexed asset, uint256 amount);

  /**
     * @notice Emitted when a user request is made asking for the funds again because the deposit request expired
     *
   * @dev The funds are returned to the user
   * @param receiver The address that will receive the funds
   * @param asset The assetType uint256
   * @param amount The amount of funds to be sent
   */
  event ReclaimFunds(address indexed receiver, address indexed asset, uint256 amount);

  /**
     * @notice Emitted when a user deposit request has is state updated and approved
   * @dev Fallback Function
   * @param receiver The address that was supposed to receive the funds
   * @param asset The assettype
   * @param amount The amount of funds that would be sent
   */
  event UnlockFunds(address indexed receiver, address indexed asset, uint256 amount);
/**
  @notice Emitted when a user withdraw request expires and a request is made to unlock funds
*/
 // event newStateEvent();

  /**
  * @notice Emitted when a withdraw is signed and completed by a user
   * @dev The funds are transfered to the user wallet and the lock is cleared allowing
   * new withdraws.
   * @param receiver The address that will receive the funds
   * @param asset The asset id
   * @param amount The amount of funds that were transfered
   */
  event Withdraw(address indexed receiver, address indexed asset, uint256 amount);

  /**
     * @notice Emitted when a user request is made to the off chain application
     * that consequently locks funds in this contract
   * @dev The funds are locked temporarily in this contract
   * @param receiver The address that will receive the funds
   * @param asset The asset address
   * @param amount The amount of funds to be sent
   */
  event LockFunds(address indexed receiver, address indexed asset, uint256 amount);

  /**
     * @notice Emitted when a user withdraw request expires and a request is made to unlock funds
   * @dev Fallback Function
   * @param receiver The address that was supposed to receive the funds
   * @param asset The asset address
   * @param amount The amount of funds that would be sent
   */
  event UnlockFunds2(address indexed receiver, address indexed asset, uint256 amount);

  /**
   * @notice Extend the 'receiver' lock
   * @dev
   * @param receiver The user that got the withdraw lock extended
   */
  event ExtendLock(address indexed receiver);

  address private updatestateAddr;


  function initializeState(
    address _layerZeroEndpoint, address up
  ) internal{

    endpoint = ILayerZeroEndpoint(_layerZeroEndpoint);
    updatestateAddr = up;

  }

  /**
     * @notice User Deposit funds on interoperability contract
   * @dev Verify if there are enough funds to lock and then lock funds

   */
  function userDepositAndLock(
    address asset,
    uint256 amount,
    address exchangeAddress
  )  external nonReentrant whenNotPaused{

      //Change this to also veridfy starkex asset with k_modulus
      require(asset != address(0), "INVALID TOKEN");
      //require(isERC20(asset), "INVALID ASSET");
      require(amount > 0, "INVALID AMOUNT");

      _lockDepositLock(0, msg.sender, asset, amount, 0, calcDepositHash(asset, amount, nonce++, block.timestamp + 3600));

      retrieveERC20(msg.sender, asset, amount);
      pendingDepositAssetSupply[asset] += amount;

      emit UserDeposit(msg.sender, asset, amount);

  }
  function calcDepositHash(
    address tokenId,
    uint256 amount,
    uint256 nonce,
    uint256 expirationTimestamp
  ) internal returns (bytes32) {
    uint256 packed_word0 = amount & MASK_64;
    packed_word0 = (packed_word0 << 32) + (nonce & MASK_32);

    uint256 packed_word1 = LIMIT_ORDER_TYPE;
    packed_word1 = (packed_word1 << 32) + (expirationTimestamp & MASK_32);
    packed_word1 = packed_word1 << 17;

    return
    keccak256(
      abi.encode(
        [
        bytes32(uint256(uint160(tokenId)) << 96 ),
        bytes32(packed_word0),
        bytes32(packed_word1)
        ]
      )
    );
  }

  function unlockDeposit(
    address receiver,
    uint branchMask,
    bytes32[] memory siblings
  ) external nonReentrant whenNotPaused onlyRole(STARKEX_CALLER){

    LockedBalance.LockUp memory lock = userDepositLock[receiver];

    PatriciaTree.verifyProof(bytes32(orderRoot), toBytes(lock.hash), toBytes(bytes32(lock.amount)), branchMask, siblings);

    _unlockDeposit(receiver);
    pendingDepositAssetSupply[lock.asset] -= lock.amount;
    totalAssetSupply[lock.asset] += lock.amount;

    emit UnlockFunds(msg.sender, lock.asset, lock.amount);

  }

  function toBytes(address a) public pure returns (bytes memory) {
    return abi.encodePacked(a);
  }

  function toBytes(bytes32 _data) public pure returns (bytes memory) {
    return abi.encodePacked(_data);
  }


  /*function reclaimFunds(
  )  external nonReentrant whenNotPaused{

    LockedBalance.LockUp storage lock = userDepositLock[msg.sender];
    require(lock.expirationDate > block.timestamp, "INVALID TIME OR WAS APPROVED");
    claimERC20(msg.sender, lock.asset, lock.amount);
    pendingDepositAssetSupply[lock.asset] -= lock.amount;


    emit ReclaimFunds(msg.sender, lock.asset, lock.amount);
  }*/








  /**
   * @notice Withdraw funds that were previously locked
   * @dev First verifies signature, then clears data and then withdraws funds
   */
  function withdrawWithSignature(
    bytes calldata starkSignature
  )  external nonReentrant whenNotPaused{

    LockedBalance.LockUp memory lock = userWithdrawLock[msg.sender];

    require(!lock.lockType, "INVALID LOCK");

    require(starkSignature.length == 32 * 3, "INVALID_LENGTH");

    bytes memory sig = starkSignature;
    (uint256 r, uint256 s, uint256 StarkKeyY) = abi.decode(sig, (uint256, uint256, uint256));

    //verify signature
    ECDSA.verify(lock.msgHash, r, s, lock.starkKey, StarkKeyY);

    //Clear locks logic
    pendingWithdrawAssetSupply[lock.asset] -= lock.amount;

    LockedBalance._unlockWithdraw(msg.sender);

    //Send funds to user
    sendSafeERC20(lock.asset, msg.sender, lock.amount);

    //emit withdraw alert to off chain application
    emit Withdraw(msg.sender, lock.asset, lock.amount);

  }


  /**
   * @notice Lock funds to be withdrawn
   * @dev Verify if there are enough funds to lock and then lock funds
   * @param receiver User address to receive funds
   * @param asset Asset address to be withdrawn
   * @param amount Amount to be withdrawn
   */
  function lockFunds(
    uint256 starkKey,
    address receiver,
    address asset,
    uint256 amount
  )  external
  nonReentrant
  whenNotPaused
  onlyRole(STARKEX_CALLER){
    require(receiver != address(0), "NON-ZERO ADDR ONLY");
    require(totalAssetSupply[asset] - pendingWithdrawAssetSupply[asset] >= amount, "INSUFFICIENT FUNDS");
    require(userWithdrawLock[receiver].expirationDate == 0, "EXISTS LOCK");
    // Validate keys and availability.
    require(starkKey != 0, "INVALID_STARK_KEY");
    require(starkKey < K_MODULUS, "INVALID_STARK_KEY");
    require(StarkKeyVerifier.isOnCurve(starkKey), "INVALID_STARK_KEY");

    //Create a lock for the funds
    LockedBalance._lockWithdrawLock(_createHash("WithdrawRequest:", receiver, asset, amount), receiver, asset, amount, starkKey);

    pendingWithdrawAssetSupply[asset] += amount;

    //emit new Lock
    emit LockFunds(receiver, asset, amount);

  }

  /**
   * @notice Unlock funds if lock expires
   * @dev Verify if lock exists and expired and deletes it returning funds to the
   * available funds
   * @param receiver User address that were to receive funds
   * @param asset Asset address that were to be withdrawn
   * @param amount Amount to be withdrawn
   */
  function unlockFunds(
    address receiver,
    address asset,
    uint256 amount
  ) external
  nonReentrant whenNotPaused  onlyRole(STARKEX_CALLER){
    require(receiver != address(0), "NON-ZERO ADDR ONLY");
    require(userWithdrawLock[receiver].expirationDate != 0 && userWithdrawLock[receiver].expirationDate < block.timestamp, "LOCK NOT EXPIRED");

    LockedBalance._unlockWithdraw(receiver);

    //Release funds to the bridge again
    pendingWithdrawAssetSupply[asset] -= amount;
    totalAssetSupply[asset] += amount;

    emit UnlockFunds2(receiver, asset, amount);

  }

  /*optional
  function extendLockByAdmins(
    address receiver,
    uint256 newDate
  )
  external
  nonReentrant
  whenNotPaused
  onlyRole(DEFAULT_ADMIN_ROLE){
    require(receiver != address(0), "NON-ZERO ADDR ONLY");

    require(userWithdrawLock[receiver].expirationDate != 0 && userWithdrawLock[receiver].expirationDate < block.timestamp, "LOCK NOT EXPIRED");
    require(userWithdrawLock[receiver].expirationDate < newDate, "DOES NOT EXTEND");

    _extendLock(receiver, newDate, false);

    emit ExtendLock(receiver);

  }*/


  function _createHash(
    string memory _msg,
    address receiver,
    address asset,
    uint256 amount
  ) private pure returns(uint256){
    return uint256(
      keccak256(abi.encodePacked(_msg, receiver, asset, amount))
    ) % ECDSA.EC_ORDER;
  }

  function registerTokenAdminCall(address _admin)external onlyRole(DEFAULT_ADMIN_ROLE){
    registerTokenAdmin(_admin);
  }

  function registerTokenCall(uint256 asset, bytes calldata info)external onlyRole(DEFAULT_ADMIN_ROLE){
    registerToken(asset, info);
  }

  function registerAvailabilityVerifierCall(address verifier, string calldata identifier) external onlyRole(DEFAULT_ADMIN_ROLE) {
    registerAvailabilityVerifier(verifier, identifier);
  }
  function registerVerifierCall(address verifier, string calldata identifier) external onlyRole(DEFAULT_ADMIN_ROLE) {
    registerVerifier(verifier, identifier);
  }



 /* function addEntryCall(
    StarkExTypes.ApprovalChainData calldata chain,
    address entry,
    uint256 maxLength,
    string memory identifier)external onlyRole(DEFAULT_ADMIN_ROLE){
    addEntry(
   chain,
  entry,
  maxLength,
  identifier
    );
  }*/


  // overrides lzReceive function in ILayerZeroReceiver.
  // automatically invoked on the receiving chain after the source chain calls endpoint.send(...)
  function lzReceive(
    uint16,
    bytes memory _fromAddress,
    uint64, /*_nonce*/
    bytes memory _payload
  ) external override {
    require(msg.sender == address(endpoint));
    address fromAddress;
    assembly {
      fromAddress := mload(add(_fromAddress, 20))
    }

    // used for testing reentrant, retry sending the payload through the relayer before the initial receive has been resolved
    // ff == '0x6666' on the payload side
    if (keccak256(abi.encodePacked((_payload))) == keccak256(abi.encodePacked((bytes10("ff"))))) {
      endpoint.receivePayload(1, bytes(""), address(0x0), 1, 1, bytes(""));
    }

    //decode the number of pings sent thus far
    (uint256[] memory publicInput, uint256[] memory applicationData) = abi.decode(_payload, (uint256[], uint256[]));

   // BridgeUpdateState.up(publicInput, applicationData);


    bytes memory payload = abi.encodeWithSignature("up(uint256[], uint256[])", publicInput, applicationData);
    (bool success, bytes memory returnData) = address(updatestateAddr).call(payload);
    require(success, "Update not succeeded");


    remoteAddressCounter[fromAddress] += 1;
    messageCounter += 1;
  }

/* function setConfig(
    uint16, /*_version
    uint16 _dstChainId,
    uint _configType,
    bytes memory _config
  ) external override {
    endpoint.setConfig(_dstChainId, endpoint.getSendVersion(address(this)), _configType, _config);
  }*/

/*  function getConfig(
    uint16, /*_dstChainId
    uint16 _chainId,
    address,
    uint _configType
  ) external view override returns (bytes memory) {
    return endpoint.getConfig(endpoint.getSendVersion(address(this)), _chainId, address(this), _configType);
  }

 /* function setSendVersion(uint16 version) external override {
    endpoint.setSendVersion(version);
  }

  function setReceiveVersion(uint16 version) external override {
    endpoint.setReceiveVersion(version);
  }

  function getSendVersion() external view returns (uint16) {
    return endpoint.getSendVersion(address(this));
  }

  function getReceiveVersion() external  view returns (uint16) {
    return endpoint.getReceiveVersion(address(this));
  }

  function forceResumeReceive(uint16 _srcChainId, bytes calldata _srcAddress) external override {
    // do nth
  }*/


  /**
    * @notice This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
   */
  uint256[100] private __gap;
}
