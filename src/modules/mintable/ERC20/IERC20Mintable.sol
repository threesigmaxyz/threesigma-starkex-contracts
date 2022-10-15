// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC20 } from "@openzeppelin/interfaces/IERC20.sol";

import { IMintable } from "src/modules/mintable/IMintable.sol";

interface IERC20Mintable is IERC20, IMintable {
    /******************************************************************************************************************************/
    /*** Events                                                                                                                 ***/
    /******************************************************************************************************************************/

    /**
     *  @dev   Emitted when new assets are minted.
     *  @param to_ The recipeint of the minted assets.
     *  @param quantity_ The amount of assets to mint.
     */
    event Minted(address to_, uint256 quantity_);
}
