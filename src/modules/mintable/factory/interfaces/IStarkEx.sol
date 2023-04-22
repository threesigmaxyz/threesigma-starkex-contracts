// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title IStarkEx
/// @author StarkExpress Team
/// @notice Interface for interacting with the StarkEx contracts.
interface IStarkEx {
    /// @notice Registers a new asset to the StarkEx system.
    /// @dev Once added, it can not be removed and there is a limited number of slots available.
    /// @param assetType_ The StarkEx asset type.
    /// @param assetInfo_ The StarkEx asset info.
    /// @param quantum_ The StarkEx asset quantum.
    function registerToken(uint256 assetType_, bytes calldata assetInfo_, uint256 quantum_) external;
}
