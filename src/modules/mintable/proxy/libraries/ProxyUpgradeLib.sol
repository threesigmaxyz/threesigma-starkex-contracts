// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title ProxyUpgradeLib
/// @author StarkExpress Team
/// @notice Library for upgrade operations on a ERC-2535 proxy.
library ProxyUpgradeLib {
    //==============================================================================//
    //=== Errors                                                                 ===//
    //==============================================================================//

    /// @notice Thrown when the upgrade action is invalid.
    error InvalidProxyUpgradeAction();

    /// @notice Thrown when an implementation is already registered for a selector.
    error ConflictingImplementation();

    /// @notice Thrown when the upgrade init call reverts.
    error InitFunctionReverted();

    /// @notice Thrown when a contract address has no deployed code.
    /// @param contract_ The contract address.
    error ContractHasNoCode(address contract_);

    //==============================================================================//
    //=== Events                                                                 ===//
    //==============================================================================//

    /// @notice Emitted when a proxy is upgraded.
    /// @param upgrade The upgrade details.
    /// @param init The initialization contract address.
    /// @param cdata The initialization contract calldata.
    event ProxyUpgraded(Upgrade upgrade, address init, bytes cdata);

    //==============================================================================//
    //=== Enums                                                                  ===//
    //==============================================================================//

    /// @notice Actions for a proxy upgrade.
    enum ProxyUpgradeAction {
        Register,
        Replace,
        Remove
    }

    //==============================================================================//
    //=== Structs                                                                ===//
    //==============================================================================//

    /// @notice A struct for storing proxy data.
    /// @param implementations Lookup table for implementation calls by selector.
    struct ProxyUpgradeStorage {
        mapping(bytes4 => address) implementations;
    }

    /// @notice Information for performing a proxy upgrade.
    /// @param action The upgrade action.
    /// @param implementation The upgrade implementation.
    /// @param selectors The list of selectors to upgrade.
    struct Upgrade {
        ProxyUpgradeAction action;
        address implementation;
        bytes4[] selectors;
    }

    //==============================================================================//
    //=== Constants                                                              ===//
    //==============================================================================//

    /// @notice Storage position for proxy upgrade operations.
    /// @dev Follows the unstructured storage pattern.
    bytes32 constant STORAGE_POSITION = keccak256("PROXY_UPGRADE_STORAGE");

    //==============================================================================//
    //=== Write API                                                              ===//
    //==============================================================================//

    /// @notice Executes a proxy upgrade.
    /// @param upgrade_ The upgrade details.
    /// @param init_ The initialization contract address.
    /// @param calldata_ The initialization contract calldata.
    function upgradeProxy(Upgrade memory upgrade_, address init_, bytes memory calldata_) internal {
        if (upgrade_.action == ProxyUpgradeAction.Register) {
            _registerImplementation(upgrade_.implementation, upgrade_.selectors, false);
        } else if (upgrade_.action == ProxyUpgradeAction.Replace) {
            _registerImplementation(upgrade_.implementation, upgrade_.selectors, true);
        } else if (upgrade_.action == ProxyUpgradeAction.Remove) {
            _removeImplementation(upgrade_.selectors);
        } else {
            revert InvalidProxyUpgradeAction();
        }

        // Emit event.
        emit ProxyUpgraded(upgrade_, init_, calldata_);

        // Initialize the proxy upgrade.
        if (init_ == address(0)) {
            return;
        }

        // Check if there is contract code in the init contract.
        _enforceHasContractCode(init_);

        // Make a delgate call to the initialization contract.
        (bool success_, bytes memory error_) = init_.delegatecall(calldata_);
        if (!success_) {
            if (error_.length > 0) {
                // Bubble up error.
                // @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(error_)
                    revert(add(32, error_), returndata_size)
                }
            } else {
                revert InitFunctionReverted();
            }
        }
    }

    //==============================================================================//
    //=== Internal                                                               ===//
    //==============================================================================//

    /// @notice Get the storage pointer.
    /// @dev Manages storage using the unstructured storage pattern.
    /// @return s Storage pointer to the proxy upgrade storage struct.
    function _storage() internal pure returns (ProxyUpgradeStorage storage s) {
        bytes32 position_ = STORAGE_POSITION;
        assembly {
            s.slot := position_
        }
    }

    /// @notice Registers the implementation address for the given selectors in the dispatch table.
    /// @param implementation_ The address of the contract implementation to be registered.
    /// @param selectors_ An array of function selectors for which the implementation addresses are to be registered.
    /// @param overwrite_ Whether to overwrite any existing implementation without requiring it to be removed first.
    function _registerImplementation(address implementation_, bytes4[] memory selectors_, bool overwrite_) internal {
        // Load storage pointer.
        ProxyUpgradeStorage storage s = _storage();

        // Check if there is contract code in the implementation.
        _enforceHasContractCode(implementation_);

        for (uint256 i_; i_ < selectors_.length;) {
            // Check collision with existing implementation.
            if (!overwrite_ && s.implementations[selectors_[i_]] != address(0)) {
                revert ConflictingImplementation();
            }

            // Set implementation for selector.
            s.implementations[selectors_[i_]] = implementation_;

            unchecked {
                ++i_;
            }
        }
    }

    /// @notice Removes the implementation address for the given selectors from the dispatch table.
    /// @param selectors_ An array of function selectors for which the implementation addresses are to be removed.
    function _removeImplementation(bytes4[] memory selectors_) internal {
        // Load storage pointer.
        ProxyUpgradeStorage storage s = _storage();

        for (uint256 i_; i_ < selectors_.length;) {
            // Remove implementation for selector.
            delete s.implementations[selectors_[i_]];
        }
    }

    /// @notice Validates that the given contract address has bytecode deployed.
    /// @dev Reverts with a `ContractHasNoCode` error if no code is deployed.
    /// @param contract_ The address of the contract to be checked.
    function _enforceHasContractCode(address contract_) internal view {
        uint256 contractSize_;
        assembly {
            contractSize_ := extcodesize(contract_)
        }

        if (contractSize_ <= 0) {
            revert ContractHasNoCode(contract_);
        }
    }
}
