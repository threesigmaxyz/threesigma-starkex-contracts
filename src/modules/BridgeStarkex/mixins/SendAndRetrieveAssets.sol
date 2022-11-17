// SPDX-License-Identifier: MIT
pragma solidity =0.8.4;

import "openzeppelin-contracts-upgradeable-master/contracts/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "openzeppelin-contracts-upgradeable-master/contracts/token/ERC20/IERC20Upgradeable.sol";

abstract contract SendAndRetrieveAssets {
  using SafeERC20Upgradeable for IERC20Upgradeable;


  /**
  * @notice Safely sends funds to users
  * @dev We assume that the sanitization was done before and do not check if the addresses are
  * valid
  */
  function sendSafeERC20(
    address receiver,
    address asset,
    uint256 amount
  ) internal {

    IERC20Upgradeable(asset).safeTransfer(receiver, amount);

  }

  /**
  * @notice Safely retrieves funds from users
  * @dev We assume that the sanitization was done before and do not check if the addresses are
  * valid
  */
  function retrieveERC20(
    address owner,
    address asset,
    uint256 amount
  ) internal {

    IERC20Upgradeable(asset).safeTransferFrom(owner, address(this), amount);

  }

  function claimERC20(
    address receiver,
    address asset,
    uint256 amount
  ) internal {

    IERC20Upgradeable(asset).safeTransferFrom(address(this), receiver, amount);

  }

  //optional function for possible future ETH withdraws
  function _sendValueWithFallbackWithdraw(
    address payable user,
    uint256 amount
  ) internal {
    if (amount == 0) {
      return;
    }

    (bool success, ) = user.call{ value: amount}("");
    require(success, "INVALID TRANSFER");
  }

  /**
    * @notice This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
   */
  uint256[100] private __gap;
}
