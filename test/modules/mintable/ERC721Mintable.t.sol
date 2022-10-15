//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC165 } from "@openzeppelin/interfaces/IERC165.sol";
import { IERC721 } from "@openzeppelin/interfaces/IERC721.sol";

import { IMintable } from "src/modules/mintable/IMintable.sol";
import { ERC721Mintable } from "src/modules/mintable/ERC721/ERC721Mintable.sol";

import { Test } from "forge-std/Test.sol";

contract ERC721MintableTest is Test {
    string private constant NAME = "Three Sigma MERC721 Token";
    string private constant SYMBOL = "TSTME721";

    event Minted(address to_, uint256 id_);

    ERC721Mintable private asset;

    function setUp() public {
        asset = new ERC721Mintable(NAME, SYMBOL, _starkEx());
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
        bytes4 erc721Selector = type(IERC721).interfaceId;
        bytes4 mintableSelector = type(IMintable).interfaceId;

        // Act
        bool erc165Result = asset.supportsInterface(erc165Selector);
        bool erc721Result = asset.supportsInterface(erc721Selector);
        bool mintableResult = asset.supportsInterface(mintableSelector);

        // Assert
        assertTrue(erc165Result && erc721Result && mintableResult);
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
        uint256 tokenId_ = 314;

        // Act
        vm.expectEmit(false, false, false, true);
        emit Minted(user_, tokenId_);
        vm.prank(_starkEx());
        asset.mintFor(user_, 1, abi.encode(tokenId_));

        // Assert
        assertEq(asset.balanceOf(user_), 1);
        assertEq(asset.ownerOf(tokenId_), user_);
    }

    function testMintFor_CallerNotStarkEx_RevertsWIthError() public {
        // Arrange
        address user_ = vm.addr(1);
        uint256 tokenId_ = 314;
        address notStarkEx_ = vm.addr(8888);

        // Act
        vm.expectRevert(abi.encodePacked("Function can only be called by StarkEx"));
        vm.prank(notStarkEx_);
        asset.mintFor(user_, 1, abi.encode(tokenId_));

        // Assert
        assertEq(asset.balanceOf(user_), 0);
        vm.expectRevert(abi.encodePacked("ERC721: invalid token ID"));
        asset.ownerOf(tokenId_);
    }

    function testMintFor_InvalidQuantity_RevertsWIthError() public {
        // Arrange
        address user_ = vm.addr(1);
        uint256 tokenId_ = 314;

        // Act
        vm.expectRevert(abi.encodePacked("Invalid mint quantity"));
        vm.prank(_starkEx());
        asset.mintFor(user_, 2, abi.encode(tokenId_));

        // Assert
        assertEq(asset.balanceOf(user_), 0);
        vm.expectRevert(abi.encodePacked("ERC721: invalid token ID"));
        asset.ownerOf(tokenId_);
    }

    function testMintFor_InvalidMintingBlob_RevertsWIthError() public {
        // TODO
    }

    function testMintFor_DuplicateId_RevertsWIthError() public {
        // Arrange
        address user_ = vm.addr(1);
        uint256 tokenId_ = 314;
        // And
        vm.prank(_starkEx());
        asset.mintFor(user_, 1, abi.encode(tokenId_));

        // Act
        vm.expectRevert(abi.encodePacked("ERC721: token already minted"));
        vm.prank(_starkEx());
        asset.mintFor(user_, 1, abi.encode(tokenId_));

        // Assert
        assertEq(asset.balanceOf(user_), 1);
        assertEq(asset.ownerOf(tokenId_), user_);
    }

    function _starkEx() private returns (address) {
        return vm.addr(12345);
    }
}
