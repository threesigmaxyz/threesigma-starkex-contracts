// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC20 } from "@openzeppelin/token/ERC20/ERC20.sol";

import { Mintable }       from "src/modules/mintable/Mintable.sol";
import { IERC20Mintable } from "src/modules/mintable/ERC20/IERC20Mintable.sol";

contract ERC20Mintable is ERC20, Mintable, IERC20Mintable {
    address public immutable starkEx;

    constructor(
        string memory name_,
        string memory symbol_,
        address starkEx_
    ) ERC20(name_, symbol_) {
        require(starkEx_ != address(0), "StarkEx must not be empty");
        starkEx = starkEx_;
    }

    modifier onlyStarkEx() {
        require(msg.sender == starkEx, "Function can only be called by StarkEx");
        _;
    }

    function mintFor(
        address to_,
        uint256 quantity_,
        bytes calldata
    ) external override onlyStarkEx {
        // validate mint quantity
        require(quantity_ >= 1, "Invalid mint quantity");

        // emit event
        emit Minted(to_, quantity_);

        // mint ERC20 tokens (minting blob is ignored)
        _mint(to_, quantity_);
    }
}
