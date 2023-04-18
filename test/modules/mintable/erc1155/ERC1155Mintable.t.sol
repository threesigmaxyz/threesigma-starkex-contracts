//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "forge-std/Test.sol";

import { IMintable } from "../../../../src/modules/mintable/core/IMintable.sol";
import { ERC1155Mintable } from "../../../../src/modules/mintable/erc1155/ERC1155Mintable.sol";

contract ERC1155MintableTest is Test {
    string private constant NAME = "Three Sigma MERC1155 Token";
    string private constant SYMBOL = "TSTME1155";
    string private constant URI = "https://starkexpress.io/";

    ERC1155Mintable private _asset;

    function setUp() public {
        _asset = new ERC1155Mintable();
        _asset.initialize(NAME, SYMBOL, URI, _starkEx());
    }

    function _starkEx() private pure returns (address) {
        return vm.addr(12_345);
    }

    // TODO
}
