// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ProxyUpgradeLib } from "../libraries/ProxyUpgradeLib.sol";
import { Ownable } from "../modifiers/Ownable.sol";

/// @title ProxyUpgradeImpl
/// @author StarkExpress Team
/// @notice Default proxy upgrade implementation for an ERC-2535 proxy.
contract ProxyUpgradeImpl is Ownable {
    //==============================================================================//
    //=== Write API                                                              ===//
    //==============================================================================//

    /// @notice Executes a proxy upgrade.
    /// @dev Only callable by the owner.
    /// @param upgrade_ The upgrade details.
    /// @param init_ The initialization contract address.
    /// @param calldata_ The initialization contract calldata.
    function upgradeProxy(ProxyUpgradeLib.Upgrade calldata upgrade_, address init_, bytes calldata calldata_)
        external
        onlyOwner
    {
        ProxyUpgradeLib.upgradeProxy(upgrade_, init_, calldata_);
    }
}
