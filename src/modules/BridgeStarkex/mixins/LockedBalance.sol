// SPDX-License-Identifier: MIT
pragma solidity =0.8.4;

import "./Constants.sol";

abstract contract LockedBalance is Constants {

  /// @notice Stores the Lock information
  /// @dev ...
  struct LockUp {

    uint256 msgHash;
    /// @notice The current owner of this withdraw request
    address payable receiver;
    /// @notice asset address
    address asset;
    /// @notice The amount Locked
    uint256 amount;
    /// @notice The Lockup expirationDate
    uint256 expirationDate;

    uint256 starkKey;

    //true -> Deposit / false -> Withdraw
    bool lockType;

    bytes32 hash;
  }

  //user => number withdraws
  uint16 public totalDepositLocksOpen;

  uint16 public totalWithdrawLocksOpen;

  //user => Lock Info
  mapping(address =>  LockUp) internal userWithdrawLock;

  mapping(address =>  LockUp) internal userDepositLock;



  function _lockDepositLock(uint256 msgHash, address receiver,
    address asset,
    uint256 amount,
    uint256 starkKey,
    bytes32 cHash
  ) internal{
    userDepositLock[receiver] = LockUp({msgHash: msgHash,
    receiver: payable(receiver),
    asset:asset,
    amount:amount,
    expirationDate: (block.timestamp + TIME_TO_FALLBACK_DEPOSIT),
    starkKey: starkKey,
    lockType: true,
    hash: cHash
    });
    totalDepositLocksOpen++;

  }



  function _lockWithdrawLock(uint256 msgHash, address receiver,
    address asset,
    uint256 amount,
    uint256 starkKey
  ) internal{
    userWithdrawLock[receiver] = LockUp({msgHash: msgHash,
    receiver: payable(receiver),
    asset:asset,
    amount:amount,
    expirationDate: (block.timestamp + TIME_TO_FALLBACK_WITHDRAW),
    starkKey: starkKey,
    lockType: false,
    hash: bytes32("")
    });
    totalWithdrawLocksOpen++;

  }

  /**
   * @notice Deletes  the lock points if the user does not withdraws
   * the funds before TIME_TO_FALLBACK_WITHDRAW or when a withdraw happens
  */
  function _unlockWithdraw(address receiver) internal{

    delete userWithdrawLock[receiver];

    totalWithdrawLocksOpen--;
  }

  function _unlockDeposit(address receiver) internal{

    delete userDepositLock[receiver];

    totalDepositLocksOpen--;
  }

  /**
   * @notice Extends the lock expiration date for any reason
  */
  function _extendLock(address receiver, uint256 newDate, bool typeLock) internal{

    if(typeLock)
      userDepositLock[receiver].expirationDate = newDate;
    else
      userWithdrawLock[receiver].expirationDate = newDate;
  }

  /**
    * @notice This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
   */
  uint256[100] private __gap;


}
