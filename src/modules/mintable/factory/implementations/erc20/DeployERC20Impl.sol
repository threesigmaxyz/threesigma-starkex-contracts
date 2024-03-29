// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Clones } from "@openzeppelin/proxy/Clones.sol";

import { ERC20Mintable } from "../../../erc20/ERC20Mintable.sol";
import { Ownable } from "../../../proxy/modifiers/Ownable.sol";
import { IStarkEx } from "../../interfaces/IStarkEx.sol";
import { BaseDeployerImpl } from "../BaseDeployerImpl.sol";

/// @title DeployERC20Impl
/// @author StarkExpress Team
/// @notice Deployer implementation for mintable ERC20 tokens.
contract DeployERC20Impl is BaseDeployerImpl, Ownable {
    //==============================================================================//
    //=== Events                                                                 ===//
    //==============================================================================//

    /// @notice Emitted when a mintable ERC20 token is deployed.
    /// @param id_ The deployment ID.
    /// @param name_ The name of the ERC20 token.
    /// @param symbol_ The symbol of the ERC20 token.
    /// @param token_ The deployed token address.
    event LogDeployERC20Mintable(uint256 indexed id_, string name_, string symbol_, address token_);

    //==============================================================================//
    //=== Constants                                                              ===//
    //==============================================================================//

    /// @notice StarkEx selector for `ERC20Mintable` tokens.
    bytes4 internal constant MINTABLE_ERC20_SELECTOR = bytes4(keccak256("MintableERC20Token(address)"));

    //==============================================================================//
    //=== Constructor                                                            ===//
    //==============================================================================//

    /// @notice Constructor for the `DeployERC20Impl` contract.
    /// @param starkEx_ The StarkEx contract address.
    constructor(address starkEx_) BaseDeployerImpl(address(new ERC20Mintable()), starkEx_) { }

    //==============================================================================//
    //=== Write API                                                              ===//
    //==============================================================================//

    /// @notice Deploy a `ERC20Mintable` contract.
    /// @dev Only callable by the owner.
    /// @param id_ The deployment ID.
    /// @param name_ The tokens' name.
    /// @param symbol_ The tokens' symbol.
    /// @param quantum_ The StarkEx asset quantum.
    /// @return token_ The deployed token address.
    function deployERC20(uint256 id_, string memory name_, string memory symbol_, uint256 quantum_)
        external
        onlyOwner
        returns (address token_)
    {
        // Deploy ERC-20 mintable token.
        token_ = Clones.cloneDeterministic(token, _getSalt(id_));
        ERC20Mintable(token_).initialize(name_, symbol_, starkEx);

        // Register token in StarkEx.
        _starkExRegister(token_, quantum_, MINTABLE_ERC20_SELECTOR);

        // Emit event.
        emit LogDeployERC20Mintable(id_, name_, symbol_, token_);
    }

    //==============================================================================//
    //=== Read API                                                               ===//
    //==============================================================================//

    /// @notice Calculate the deployment address of a `ERC20Mintable` contract.
    /// @dev Computes the address of a clone deployed using CREATE2.
    /// @param id_ The deployment ID.
    /// @return deploymentAddress_ The contract deployment address.
    function getERC20DeploymentAddress(uint256 id_) external view returns (address deploymentAddress_) {
        deploymentAddress_ = Clones.predictDeterministicAddress(token, _getSalt(id_));
    }
}
