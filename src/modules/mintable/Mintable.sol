// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC165 } from "@openzeppelin/interfaces/IERC165.sol";
import { ERC165 }  from "@openzeppelin/utils/introspection/ERC165.sol";

import { IMintable } from "src/modules/mintable/IMintable.sol";

abstract contract Mintable is ERC165, IMintable {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IMintable).interfaceId || super.supportsInterface(interfaceId);
    }
}
