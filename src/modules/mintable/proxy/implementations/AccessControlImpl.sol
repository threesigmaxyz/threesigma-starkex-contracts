// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { AccessControlLib } from "../libraries/AccessControlLib.sol";
import { Ownable } from "../modifiers/Ownable.sol";

/// @title AccessControlImpl
/// @author StarkExpress Team
/// @notice Default access control implementation for an ERC-2535 proxy.
contract AccessControlImpl is Ownable {
    //==============================================================================//
    //=== Write API                                                              ===//
    //==============================================================================//

    /// @notice Sets the msg.sender address to a role.
    /// @param role_ The role.
    function acceptRole(bytes32 role_) external {
        AccessControlLib.acceptRole(role_);
    }

    /// @notice Sets a pending address to a role.
    /// @dev Only callable by the owner role.
    /// @param role_ The role.
    /// @param account_ The address of the pending account.
    function setPendingRole(bytes32 role_, address account_) external onlyOwner {
        AccessControlLib.setPendingRole(role_, account_);
    }

    //==============================================================================//
    //=== Read API                                                               ===//
    //==============================================================================//

    /// @notice Gets the account assigned to a role.
    /// @param role_ The role.
    /// @return The address.
    function getRole(bytes32 role_) external view returns (address) {
        return AccessControlLib.getRole(role_);
    }
}
