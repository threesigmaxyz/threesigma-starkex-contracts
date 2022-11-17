// SPDX-License-Identifier: MIT
pragma solidity =0.8.4;

import "openzeppelin-contracts-upgradeable-master/contracts/proxy/utils/Initializable.sol";


import  "./mixins/BridgeBasicOperations.sol";
import "./mixins/BridgeCore.sol";

/**
 * @dev k
 */
contract Bridge is
Initializable,
BridgeCore,

BridgeBasicOperations
{

  /**
   * @notice Initialize upgradable contracts
   * @dev Set access control addresses and initialize parameters
   * new withdraws.
   */
  function initialize(
    address starkex_caller,
    address l1Setter,
    address up
  ) external initializer {
    BridgeCore.initializeCore(starkex_caller, l1Setter);
    BridgeBasicOperations.initializeState(l1Setter, up);
  }



}
