// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Proxy } from "../proxy/Proxy.sol";
import { AccessControlLib } from "../proxy/libraries/AccessControlLib.sol";

/// @title DeployERC721Impl
/// @author StarkExpress Team
/// @notice Factory contract for mintable tokens in the StarkExpress platform.
/// @dev Can be extended to support the deployment of other token types.
contract TokenFactory is Proxy {
    //==============================================================================//
    //=== Constructor                                                            ===//
    //==============================================================================//

    /// @notice Constructor for the `TokenFactory` contract.
    constructor() {
        AccessControlLib.setRole(AccessControlLib.OWNER_ROLE, msg.sender);
    }
}
