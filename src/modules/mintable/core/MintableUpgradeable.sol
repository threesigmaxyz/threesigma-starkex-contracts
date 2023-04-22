// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC165 } from "@openzeppelin/interfaces/IERC165.sol";
import { ERC165 } from "@openzeppelin/utils/introspection/ERC165.sol";
import { Initializable } from "@openzeppelin-upgradeable/proxy/utils/Initializable.sol";

import { IMintable } from "./IMintable.sol";

/// @title MintableUpgradeable
/// @author StarkExpress Team
/// @notice Base abstract class for mintable upgradeable StarkExpress tokens.
abstract contract MintableUpgradeable is Initializable, ERC165, IMintable {
    //==============================================================================//
    //=== Errors                                                                 ===//
    //==============================================================================//

    /// @notice An unauthorized operation was requested.
    error NotAuthorizedError();

    /// @notice An argument with a non-zero value is passed as zero.
    error ZeroValueError();

    //==============================================================================//
    //=== State Variables                                                        ===//
    //==============================================================================//

    /// @notice The StarkEx contract address.
    address public starkEx;

    //==============================================================================//
    //=== Modifiers                                                              ===//
    //==============================================================================//

    /// @notice Throws if called by any account other than the StarkEx contract.
    modifier onlyStarkEx() {
        if (msg.sender != starkEx) {
            revert NotAuthorizedError();
        }
        _;
    }

    //==============================================================================//
    //=== Initializers                                                            ===//
    //==============================================================================//

    function __Mintable_init(address starkEx_) internal onlyInitializing {
        if (starkEx_ == address(0)) revert ZeroValueError();
        starkEx = starkEx_;
    }

    //==============================================================================//
    //=== Read API                                                               ===//
    //==============================================================================//

    /// @dev See {IERC165-supportsInterface}.
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IMintable).interfaceId || super.supportsInterface(interfaceId);
    }
}
