// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC20 } from "@openzeppelin/token/ERC20/ERC20.sol";

contract ERC20Faucet is ERC20 {

    constructor(
        string memory name_,
        string memory symbol_,
        address _faucet
    ) ERC20(name_, symbol_) {
        _mint(_faucet, 2**256 - 1);
    }
}
