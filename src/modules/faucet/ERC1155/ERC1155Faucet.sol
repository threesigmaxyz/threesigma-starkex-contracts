// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC1155 } from "@openzeppelin/token/ERC1155/ERC1155.sol";

contract ERC1155Faucet is ERC1155 {
    address public immutable faucet;

    constructor(
        string memory uri_,
        address faucet_
    ) ERC1155(uri_) {
        require(faucet_ != address(0), "Faucet must not be empty");
        faucet = faucet_;
    }

    modifier onlyFaucet() {
        require(msg.sender == faucet, "Function can only be called by Faucet");
        _;
    }

    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual onlyFaucet {
        _mint(to, id, amount, data);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual onlyFaucet {
        _mintBatch(to, ids, amounts, data);
    }
}
