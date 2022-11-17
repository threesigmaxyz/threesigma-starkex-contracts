// SPDX-License-Identifier: MIT
pragma solidity =0.8.4;

import "openzeppelin-contracts-upgradeable-master/contracts/utils/AddressUpgradeable.sol";
import "openzeppelin-contracts-upgradeable-master/contracts/access/AccessControlUpgradeable.sol";

import "../interfaces/LayerZero/ILayerZeroEndpoint.sol";

/**
 * @title A place for common modifiers and functions used by various  mixins, if any.
 * @dev This also leaves a gap which can be used to add a new mixin to the top of the inheritance tree.
 */
abstract contract BridgeCore is AccessControlUpgradeable{
  using AddressUpgradeable for address;

  bytes32 public constant STARKEX_CALLER = keccak256("STARKEX_CALLER");
  bytes32 public constant L1STATE_CALLER = keccak256("L1STATE_CALLER");

  //asset => value
  mapping(address => uint256) public totalAssetSupply;

  function initializeCore(
    address starkex_caller_init,
    address _layerZeroEndpoint
  ) internal{

    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(STARKEX_CALLER, starkex_caller_init);
    _setupRole(L1STATE_CALLER, _layerZeroEndpoint);

  }

  /**
   * @notice This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
   * @dev 50 slots were consumed by adding `ReentrancyGuard`.
   */
  uint256[100] private __gap;
}
