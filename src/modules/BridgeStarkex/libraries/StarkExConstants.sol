// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.8.0;

import "./LibConstants.sol";

contract StarkExConstants is LibConstants {
  uint256 constant STARKEX_EXPIRATION_TIMESTAMP_BITS = 22;
  uint256 public constant STARKEX_MAX_DEFAULT_VAULT_LOCK = 7 days;
}
