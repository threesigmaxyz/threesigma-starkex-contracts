// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title AccessControlLib
/// @author StarkExpress Team
/// @notice Library for access control operations on a ERC-2535 proxy.
library AccessControlLib {
    //==============================================================================//
    //=== Errors                                                                 ===//
    //==============================================================================//

    /// @notice Thrown when an unathorized access is requested.
    error UnauthorizedError();

    /// @notice Thrown when the role acceptance request is invalid.
    error NotPendingRoleError();

    //==============================================================================//
    //=== Events                                                                 ===//
    //==============================================================================//

    /// @notice Emitted when a pending role is set for an account.
    /// @param role The role.
    /// @param newAccount The new account assigned.
    event LogSetPendingRole(bytes32 indexed role, address indexed newAccount);

    /// @notice Emitted when a role was set for an account.
    /// @param role The role.
    /// @param newAccount The new account assigned.
    event LogRoleTransferred(bytes32 indexed role, address indexed newAccount);

    //==============================================================================//
    //=== Structs                                                                ===//
    //==============================================================================//

    /// @notice A struct for storing access control data.
    /// @param roles The current access control roles.
    /// @param pendingRoles The pending access control roles.
    struct AccessControlStorage {
        mapping(bytes32 => address) roles;
        mapping(bytes32 => address) pendingRoles;
    }

    //==============================================================================//
    //=== Constants                                                              ===//
    //==============================================================================//

    /// @notice Storage position for access control operations.
    /// @dev Follows the unstructured storage pattern.
    bytes32 constant STORAGE_POSITION = keccak256("ACCESS_CONTROL_STORAGE_POSITION");

    /// @notice Role for owner operations.
    bytes32 constant OWNER_ROLE = keccak256("OWNER_ROLE");

    //==============================================================================//
    //=== Modifiers                                                              ===//
    //==============================================================================//

    /// @notice Throws if called by any account other than the one assigned to the role.
    /// @param role_ The role.
    function onlyRole(bytes32 role_) internal view {
        if (msg.sender != _storage().roles[role_]) revert UnauthorizedError();
    }

    //==============================================================================//
    //=== Write API                                                              ===//
    //==============================================================================//

    /// @notice Sets the role to a account in a single opration.
    /// @dev Bypasses the requirement for the pending role.
    /// @param role_ The role.
    /// @param account_ The address of the account.
    function setRole(bytes32 role_, address account_) internal {
        // Load a storage pointer.
        AccessControlStorage storage s = _storage();

        // Set the new role account.
        s.roles[role_] = account_;

        // Delete any pending role request.
        delete s.pendingRoles[role_];

        // Emit an event.
        emit LogRoleTransferred(role_, account_);
    }

    /// @notice Sets the role to a pending account.
    /// @param role_ The role.
    /// @param account_ The address of the pending account.
    function setPendingRole(bytes32 role_, address account_) internal {
        // Load a storage pointer.
        AccessControlStorage storage s = _storage();

        // Set the pending role request.
        s.pendingRoles[role_] = account_;

        // Emit an event.
        emit LogSetPendingRole(role_, account_);
    }

    /// @notice Accepts the given role.
    /// @param role_ The role.
    function acceptRole(bytes32 role_) internal {
        // Load a storage pointer.
        AccessControlStorage storage s = _storage();

        // Check if there is a matching pending role.
        if (msg.sender != s.pendingRoles[role_]) {
            revert NotPendingRoleError();
        }

        // Set the new role account.
        s.roles[role_] = msg.sender;

        // Delete any pending role request.
        delete s.pendingRoles[role_];

        // Emit an event.
        emit LogRoleTransferred(role_, msg.sender);
    }

    //==============================================================================//
    //=== Read API                                                               ===//
    //==============================================================================//

    /// @notice Gets the account assigned to a role.
    /// @param role_ The role.
    /// @return The address.
    function getRole(bytes32 role_) internal view returns (address) {
        return _storage().roles[role_];
    }

    //==============================================================================//
    //=== Internal                                                               ===//
    //==============================================================================//

    /// @notice Get the storage pointer.
    /// @dev Manages storage using the unstructured storage pattern.
    /// @return s Storage pointer to the access control storage struct.
    function _storage() internal pure returns (AccessControlStorage storage s) {
        bytes32 position_ = STORAGE_POSITION;
        assembly {
            s.slot := position_
        }
    }
}
