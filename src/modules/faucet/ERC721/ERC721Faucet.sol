// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC721 } from "@openzeppelin/token/ERC721/ERC721.sol";

contract ERC721Faucet is ERC721 {
    address public immutable faucet;

    constructor(
        string memory name_,
        string memory symbol_,
        address faucet_
    ) ERC721(name_, symbol_) {
        require(faucet_ != address(0), "Faucet must not be empty");
        faucet = faucet_;
    }

    modifier onlyFaucet() {
        require(msg.sender == faucet, "Function can only be called by Faucet");
        _;
    }

    function safeMint(
        address to,
        uint256 tokenId
    ) public virtual onlyFaucet {
        _safeMint(to, tokenId);
    }
}
