// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC721 } from "@openzeppelin/interfaces/IERC721.sol";

import { IMintable } from "src/modules/mintable/IMintable.sol";

interface IERC721Mintable is IERC721, IMintable {
    /******************************************************************************************************************************/
    /*** Events                                                                                                                 ***/
    /******************************************************************************************************************************/

    /**
     *  @dev   Emitted when a new asset is minted.
     *  @param to_ The recipeint of the minted asset.
     *  @param id_ The unique ID asset to mint.
     */
    event Minted(address to_, uint256 id_);
}
