// SPDX-License-Identifier: MIT
pragma solidity =0.8.4;

/**
 * @title Constant values shared across mixins.
 */

abstract contract Constants {
  /**
   * @notice 100% in basis points.
   */
  uint256 internal constant BASIS_POINTS = 100_00;

  uint256 internal constant TIME_TO_FALLBACK_WITHDRAW = 3600 * 10; //10 hours

  uint256 internal constant TIME_TO_FALLBACK_DEPOSIT = 3600 * 12; //10 hours

  //Deprecated
  //uint256 internal constant MAX_CONCURRENT_WITHDRAWALS = 10; //10 hours

  //Duplicated
  //uint256 constant K_MODULUS = 0x800000000000011000000000000000000000000000000000000000000000001;
}
