// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Clones } from "@openzeppelin/proxy/Clones.sol";

import { ERC721Mintable } from "../../../erc721/ERC721Mintable.sol";
import { Ownable } from "../../../proxy/modifiers/Ownable.sol";
import { IStarkEx } from "../../interfaces/IStarkEx.sol";
import { BaseDeployerImpl } from "../BaseDeployerImpl.sol";

/// @title DeployERC721Impl
/// @author StarkExpress Team
/// @notice Deployer implementation for mintable ERC721 tokens.
contract DeployERC721Impl is BaseDeployerImpl, Ownable {
    //==============================================================================//
    //=== Events                                                                 ===//
    //==============================================================================//

    /// @notice Emitted when a mintable ERC721 token is deployed.
    /// @param id_ The deployment ID.
    /// @param name_ The name of the ERC721 token.
    /// @param symbol_ The symbol of the ERC721 token.
    /// @param uri_ The base URI of the ERC721 token.
    /// @param token_ The deployed token address.
    event LogDeployERC721Mintable(
        uint256 indexed id_, string name_, string symbol_, string uri_, address token_
    );

    //==============================================================================//
    //=== Constants                                                              ===//
    //==============================================================================//

    /// @notice StarkEx selector for `ERC721Mintable` tokens.
    bytes4 internal constant MINTABLE_ERC721_SELECTOR = bytes4(keccak256("MintableERC721Token(address,uint256)"));

    //==============================================================================//
    //=== Constructor                                                            ===//
    //==============================================================================//

    /// @notice Constructor for the `DeployERC721Impl` contract.
    /// @param starkEx_ The StarkEx contract address.
    constructor(address starkEx_) BaseDeployerImpl(address(new ERC721Mintable()), starkEx_) { }

    //==============================================================================//
    //=== Write API                                                              ===//
    //==============================================================================//

    /// @notice Deploy a `ERC721Mintable` contract.
    /// @dev Only callable by the owner.
    /// @param id_ The deployment ID.
    /// @param name_ The tokens' name.
    /// @param symbol_ The tokens' symbol.
    /// @param uri_ The token's URI.
    /// @return token_ The deployed token address.
    function deployERC721(uint256 id_, string memory name_, string memory symbol_, string memory uri_)
        external
        onlyOwner
        returns (address token_)
    {
        // Deploy ERC-721 mintable token.
        token_ = Clones.cloneDeterministic(token, _getSalt(id_));
        ERC721Mintable(token_).initialize(name_, symbol_, uri_, starkEx);

        // Register token in StarkEx.
        _starkExRegister(token_, 1, MINTABLE_ERC721_SELECTOR);

        // Emit event.
        emit LogDeployERC721Mintable(id_, name_, symbol_, uri_, token_);
    }

    //==============================================================================//
    //=== Read API                                                               ===//
    //==============================================================================//

    /// @notice Calculate the deployment address of a `ERC721Mintable` contract.
    /// @dev Computes the address of a clone deployed using CREATE2.
    /// @param id_ The deployment ID.
    /// @param deploymentAddress_ The contract deployment address.
    function getERC721DeploymentAddress(uint256 id_) external view returns (address deploymentAddress_) {
        deploymentAddress_ = Clones.predictDeterministicAddress(token, _getSalt(id_));
    }
}
