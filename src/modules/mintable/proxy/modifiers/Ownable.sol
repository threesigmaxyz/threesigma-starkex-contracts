// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { AccessControlLib } from "../libraries/AccessControlLib.sol";

/// @title Ownable
/// @author StarkExpress Team
abstract contract Ownable {
    modifier onlyOwner() {
        AccessControlLib.onlyRole(AccessControlLib.OWNER_ROLE);
        _;
    }
}
