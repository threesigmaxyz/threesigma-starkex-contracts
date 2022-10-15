//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC165 } from "@openzeppelin/interfaces/IERC165.sol";

import { IMintable } from "src/modules/mintable/IMintable.sol";
import { ERC20Mintable } from "src/modules/mintable/ERC20/ERC20Mintable.sol";

import { Test } from "forge-std/Test.sol";

contract ERC20MintableTest is Test {
    string private constant NAME = "Three Sigma MERC20 Token";
    string private constant SYMBOL = "TSTME20";

    event Minted(address to_, uint256 quantity_);

    ERC20Mintable private asset;

    function setUp() public {
        asset = new ERC20Mintable(NAME, SYMBOL, _starkEx());
    }

    function test_constructor() public {
        // Assert
        assertEq(asset.name(), NAME);
        assertEq(asset.symbol(), SYMBOL);
        assertEq(asset.starkEx(), _starkEx());
    }

    function test_supportsInterface_success() public {
        // Arrange
        bytes4 erc165Selector = type(IERC165).interfaceId;
        bytes4 mintableSelector = type(IMintable).interfaceId;

        // Act
        bool erc165Result = asset.supportsInterface(erc165Selector);
        bool mintableResult = asset.supportsInterface(mintableSelector);

        // Assert
        assertTrue(erc165Result && mintableResult);
    }

    function test_supportsInterface_interfaceNotSupported() public {
        // Arrange
        bytes4 selector = 0x0badc0d3;

        // Act
        bool result = asset.supportsInterface(selector);

        // Assert
        assertFalse(result);
    }

    function testMintFor_HappyPath_Success() public {
        // Arrange
        address user_ = vm.addr(1);
        uint256 quantity_ = 314159265;

        // Act
        vm.expectEmit(false, false, false, true);
        emit Minted(user_, quantity_);
        vm.prank(_starkEx());
        asset.mintFor(user_, quantity_, "");

        // Assert
        assertEq(asset.totalSupply(), quantity_);
        assertEq(asset.balanceOf(user_), quantity_);
    }

    function testMintFor_CallerNotStarkEx_RevertsWIthError() public {
        // Arrange
        address user_ = vm.addr(1);
        uint256 quantity_ = 314159265;
        address notStarkEx_ = vm.addr(8888);

        // Act
        vm.expectRevert(abi.encodePacked("Function can only be called by StarkEx"));
        vm.prank(notStarkEx_);
        asset.mintFor(user_, quantity_, "");
    }

    function testMintFor_InvalidQuantity_RevertsWIthError() public {
        // Arrange
        address user_ = vm.addr(1);

        // Act
        vm.expectRevert(abi.encodePacked("Invalid mint quantity"));
        vm.prank(_starkEx());
        asset.mintFor(user_, 0, "");
    }

    function _starkEx() private returns (address) {
        return vm.addr(12345);
    }
}
