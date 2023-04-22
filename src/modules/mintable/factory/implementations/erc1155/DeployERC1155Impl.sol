// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Clones } from "@openzeppelin/proxy/Clones.sol";

import { ERC1155Mintable } from "../../../erc1155/ERC1155Mintable.sol";
import { Ownable } from "../../../proxy/modifiers/Ownable.sol";
import { BaseDeployerImpl } from "../BaseDeployerImpl.sol";

/// @title DeployERC1155Impl
/// @author StarkExpress Team
/// @notice Deployer implementation for mintable ERC1155 tokens.
/// @dev Will only be enabled in StarkEx V5.
contract DeployERC1155Impl is BaseDeployerImpl, Ownable {
    //==============================================================================//
    //=== Events                                                                 ===//
    //==============================================================================//

    /// @notice Emitted when a mintable ERC1155 token is deployed.
    /// @param id_ The deployment ID.
    /// @param name_ The name of the ERC1155 token.
    /// @param symbol_ The symbol of the ERC1155 token.
    /// @param uri_ The base URI of the ERC1155 token.
    /// @param token_ The deployed token address.
    event LogDeployERC1155Mintable(
        uint256 indexed id_, string name_, string symbol_, string uri_, address token_
    );

    //==============================================================================//
    //=== Constants                                                              ===//
    //==============================================================================//

    /// @notice StarkEx selector for `ERC1155Mintable` tokens.
    bytes4 internal constant MINTABLE_ERC1155_SELECTOR = bytes4(keccak256("MintableERC1155Token(address,uint256)"));

    //==============================================================================//
    //=== Constructor                                                            ===//
    //==============================================================================//

    /// @notice Constructor for the `DeployERC1155Impl` contract.
    /// @param starkEx_ The StarkEx contract address.
    constructor(address starkEx_) BaseDeployerImpl(address(new ERC1155Mintable()), starkEx_) { }

    //==============================================================================//
    //=== Write API                                                              ===//
    //==============================================================================//

    /// @notice Deploy a `ERC1155Mintable` contract.
    /// @dev Only callable by the owner.
    /// @param id_ The deployment ID.
    /// @param name_ The tokens' name.
    /// @param symbol_ The tokens' symbol.
    /// @param uri_ The token's URI.
    /// @param quantum_ The StarkEx asset quantum.
    /// @return token_ The deployed token address.
    function deployERC1155(
        uint256 id_,
        string memory name_,
        string memory symbol_,
        string memory uri_,
        uint256 quantum_
    ) external onlyOwner returns (address token_) {
        // Deploy ERC-1155 mintable token.
        token_ = Clones.cloneDeterministic(token, _getSalt(id_));
        ERC1155Mintable(token_).initialize(name_, symbol_, uri_, starkEx);

        // Register token in StarkEx.
        _starkExRegister(token_, quantum_, MINTABLE_ERC1155_SELECTOR);

        // Emit event.
        emit LogDeployERC1155Mintable(id_, name_, symbol_, uri_, token_);
    }

    //==============================================================================//
    //=== Read API                                                               ===//
    //==============================================================================//

    /// @notice Calculate the deployment address of a `ERC1155Mintable` contract.
    /// @dev Computes the address of a clone deployed using CREATE2.
    /// @param id_ The deployment ID.
    /// @return deploymentAddress_ The contract deployment address.
    function getERC1155DeploymentAddress(uint256 id_) external view returns (address deploymentAddress_) {
        deploymentAddress_ = Clones.predictDeterministicAddress(token, _getSalt(id_));
    }
}
