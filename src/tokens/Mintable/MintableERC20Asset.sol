// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "./../ERC20/ERC20.sol";
import "./MintableERC20.sol";

contract MintableERC20Asset is ERC20, MintableERC20 {
    constructor(
        address _owner,
        string memory _name,
        string memory _symbol,
        address _operator
    ) public ERC20(_name, _symbol) MintableERC20(_owner, _operator) {}

    function _mintFor(address user, uint256 quantity) internal override {
        _mint(user, quantity);
    }
}
