// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IStarkEx } from "../interfaces/IStarkEx.sol";

/// @title BaseDeployerImpl
/// @author StarkExpress Team
/// @notice Base deployer implementation for StarkExpress mintable tokens.
abstract contract BaseDeployerImpl {
    //==============================================================================//
    //=== Constants                                                              ===//
    //==============================================================================//

    /// @notice Bit mask for the first 250 bits.
    /// @dev Used when calculating StarkEx asset types.
    uint256 internal constant MASK_250 = 0x03FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    //==============================================================================//
    //=== State Variables                                                        ===//
    //==============================================================================//

    /// @notice The token implementation address.
    address public immutable token;

    /// @notice The StarkEx contract address.
    address public immutable starkEx;

    //==============================================================================//
    //=== Constructor                                                            ===//
    //==============================================================================//

    /// @notice Constructor for the `BaseDeployerImpl` contract.
    /// @param token_ The token implementation address.
    /// @param starkEx_ The StarkEx contract address.
    constructor(address token_, address starkEx_) {
        token = token_;
        starkEx = starkEx_;
    }

    //==============================================================================//
    //=== Internals                                                              ===//
    //==============================================================================//

    /// @notice Calculate the contract deployment salt.
    /// @notice The deployment ID.
    /// @return salt_ The deployment salt.
    function _getSalt(uint256 id_) internal pure returns (bytes32 salt_) {
        salt_ = keccak256(abi.encode(id_));
    }

    /// @notice Register a token in the StarkEx contracts.
    /// @param token_ The token address.
    /// @param quantum_ The StarkEx asset quantum.
    /// @param selector_ The StarkEx asset type selector.
    /// @return assetType_ The StarkEx asset type for the token.
    function _starkExRegister(address token_, uint256 quantum_, bytes4 selector_)
        internal
        returns (uint256 assetType_)
    {
        // Calculate StarkEx asset identifiers.
        bytes memory assetInfo_ = abi.encodePacked(selector_, abi.encode(token_));
        assetType_ = uint256(keccak256(abi.encodePacked(assetInfo_, quantum_))) & MASK_250;

        // Register token in StarkEx.
        IStarkEx(starkEx).registerToken(assetType_, assetInfo_, quantum_);
    }
}
