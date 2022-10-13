// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "./../ERC721/ERC721.sol";
import "./MintableERC721.sol";

contract MintableERC721Asset is ERC721, MintableERC721 {
    constructor(
        address _owner,
        string memory _name,
        string memory _symbol,
        address _operator
    ) public ERC721(_name, _symbol) MintableERC721(_owner, _operator) {}

    function _mintFor(
        address user,
        uint256 id,
        bytes memory
    ) internal override {
        _mint(user, id);
    }
}
