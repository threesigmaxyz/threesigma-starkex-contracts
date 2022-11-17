// SPDX-License-Identifier: MIT
pragma solidity =0.8.4;

/**
 * @notice Interface for the bridge contract
 */
interface IBridge {

  function withdrawWithSignature(
    bytes calldata starkSignature
  ) external;

/*  function userDepositAndLock(
    uint256 asset,
    uint256 amount
  ) external;*/

  function lockFunds(
    uint256 starkKey,
    address receiver,
    uint256 asset,
    uint256 amount
  )
  external;

  function unlockFunds(
    address receiver,
    uint256 asset,
    uint256 amount
  )
  external;
}
