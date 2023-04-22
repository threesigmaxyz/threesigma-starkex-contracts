// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC165 } from "@openzeppelin/interfaces/IERC165.sol";

/// @title IMintable
/// @author StarkExpress Team
/// @notice Interface for mintable StarkExpress tokens.
interface IMintable is IERC165 {
    /// @notice Mints tokens to a specified address.
    /// @param to_ The address that will receive the minted tokens.
    /// @param amount_ The amount of tokens to mint.
    /// @param mintingBlob_ Additional data needed for the minting process.
    function mintFor(address to_, uint256 amount_, bytes calldata mintingBlob_) external;
}
