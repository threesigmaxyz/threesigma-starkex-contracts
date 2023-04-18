// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC20Upgradeable } from "@openzeppelin-upgradeable/token/ERC20/ERC20Upgradeable.sol";

import { IMintable } from "../core/IMintable.sol";
import { MintableUpgradeable } from "../core/MintableUpgradeable.sol";

/// @title ERC20Mintable
/// @author StarkExpress Team
/// @notice Base implementation for StarkExpress ERC-20 mintable tokens.
contract ERC20Mintable is ERC20Upgradeable, MintableUpgradeable {
    //==============================================================================//
    //=== Errors                                                                 ===//
    //==============================================================================//

    /// @notice Thrown when an invalid mint amount is requested.
    error InvalidMintAmountError();

    //==============================================================================//
    //=== Events                                                                 ===//
    //==============================================================================//

    /// @notice Emitted when ERC20 tokens are minted.
    /// @param to_ The minted tokens recipient.
    /// @param amount_ The minted tokens amount.
    event LogMintedERC20(address indexed to_, uint256 amount_);

    //==============================================================================//
    //=== Initialization                                                         ===//
    //==============================================================================//

    /// @notice Initialization function for the `ERC20Mintable` contract.
    /// @param name_ The tokens' name.
    /// @param symbol_ The tokens' symbol.
    /// @param starkEx_ The StarkEx contract address.
    function initialize(string memory name_, string memory symbol_, address starkEx_) external initializer {
        __ERC20_init(name_, symbol_);
        __Mintable_init(starkEx_);
    }

    //==============================================================================//
    //=== Write API                                                              ===//
    //==============================================================================//

    /// @inheritdoc IMintable
    /// @dev Only callable by the StarkEx contract.
    function mintFor(address to_, uint256 amount_, bytes calldata) external override onlyStarkEx {
        // validate mint amount
        if (amount_ < 1) {
            revert InvalidMintAmountError();
        }

        // emit event
        emit LogMintedERC20(to_, amount_);

        // mint ERC20 tokens
        _mint(to_, amount_);
    }
}
