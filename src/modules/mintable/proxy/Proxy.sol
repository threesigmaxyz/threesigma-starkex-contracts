// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { AccessControlImpl } from "./implementations/AccessControlImpl.sol";
import { ProxyUpgradeImpl } from "./implementations/ProxyUpgradeImpl.sol";
import { ProxyUpgradeLib } from "./libraries/ProxyUpgradeLib.sol";

/// @title Proxy
/// @author StarkExpress Team
/// @notice Minimal implementation for a ERC-2535 proxy.
contract Proxy {
    //==============================================================================//
    //=== Errors                                                                 ===//
    //==============================================================================//

    /// @notice Thrown when no implementation is registered for a given selector.
    error ImplementationNotFound();

    //==============================================================================//
    //=== Constructor                                                            ===//
    //==============================================================================//

    /// @notice Constructor for the `Proxy` contract.
    /// @dev Deploys and registers a default `ProxyUpgradeImpl` implementation.
    constructor() {
        ProxyUpgradeLib.Upgrade memory upgrade_;

        // Deploy and register default access control implementation.
        address accesssControlImpl_ = address(new AccessControlImpl());
        bytes4[] memory accesssControlSelectors_ = new bytes4[](3);
        accesssControlSelectors_[0] = AccessControlImpl.acceptRole.selector;
        accesssControlSelectors_[1] = AccessControlImpl.setPendingRole.selector;
        accesssControlSelectors_[2] = AccessControlImpl.getRole.selector;
        upgrade_ = ProxyUpgradeLib.Upgrade({
            action: ProxyUpgradeLib.ProxyUpgradeAction.Register,
            implementation: accesssControlImpl_,
            selectors: accesssControlSelectors_
        });
        ProxyUpgradeLib.upgradeProxy(upgrade_, address(0), "");

        // Deploy and register default proxy upgrade implementation.
        address proxyUpgradeImpl_ = address(new ProxyUpgradeImpl());
        bytes4[] memory proxyUpgradeSelectors_ = new bytes4[](1);
        proxyUpgradeSelectors_[0] =ProxyUpgradeImpl.upgradeProxy.selector;
        upgrade_ = ProxyUpgradeLib.Upgrade({
            action: ProxyUpgradeLib.ProxyUpgradeAction.Register,
            implementation: proxyUpgradeImpl_,
            selectors: proxyUpgradeSelectors_
        });
        ProxyUpgradeLib.upgradeProxy(upgrade_, address(0), "");
    }

    //==============================================================================//
    //=== Fallback                                                               ===//
    //==============================================================================//

    /// @notice Fallback function that delegates execution to the implementation contract.
    fallback() external payable {
        // Load storage reference to proxy implementation.
        ProxyUpgradeLib.ProxyUpgradeStorage storage s;
        bytes32 position_ = ProxyUpgradeLib.STORAGE_POSITION;
        assembly {
            s.slot := position_
        }

        // Get implementation from function selector.
        address implementation_ = s.implementations[msg.sig];
        if (implementation_ == address(0)) {
            revert ImplementationNotFound();
        }

        // Execute external function from implementation using delegatecall.
        _delegate(implementation_);
    }

    //==============================================================================//
    //=== Internals                                                              ===//
    //==============================================================================//

    /// @notice Delegates the current call to `implementation`.
    /// @dev Does not return to its internal call site, returns directly to the external caller.
    /// @param implementation_ The implementation to delegate call.
    function _delegate(address implementation_) internal {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result_ := delegatecall(gas(), implementation_, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result_
            // delegatecall returns 0 on error.
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}
