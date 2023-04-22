//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC165 } from "@openzeppelin/interfaces/IERC165.sol";
import { IERC721Upgradeable } from "@openzeppelin-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import { Test } from "forge-std/Test.sol";

import { IMintable } from "../../../../src/modules/mintable/core/IMintable.sol";
import { Mintable } from "../../../../src/modules/mintable/core/Mintable.sol";
import { ERC721Mintable } from "../../../../src/modules/mintable/erc721/ERC721Mintable.sol";
import { ByteUtils } from "../../../../src/modules/mintable/utils/ByteUtils.sol";

contract ERC721MintableTest is Test {
    //==============================================================================//
    //=== Events                                                                 ===//
    //==============================================================================//

    event LogMintedERC721(address indexed to_, uint256 tokenId_);

    //==============================================================================//
    //=== Constants                                                              ===//
    //==============================================================================//

    string private constant NAME = "Three Sigma MERC721 Token";
    string private constant SYMBOL = "TSTME721";
    string private constant URI = "https://starkexpress.io/";

    //==============================================================================//
    //=== State Variables                                                        ===//
    //==============================================================================//

    ERC721Mintable private _asset;

    //==============================================================================//
    //=== SetUp                                                                  ===//
    //==============================================================================//

    function setUp() public {
        _asset = new ERC721Mintable();
        _asset.initialize(NAME, SYMBOL, URI, _starkEx());
    }

    //==============================================================================//
    //=== Tests                                                                  ===//
    //==============================================================================//

    function test_constructor() public {
        // Assert
        assertEq(_asset.name(), NAME);
        assertEq(_asset.symbol(), SYMBOL);
        assertEq(_asset.starkEx(), _starkEx());
    }

    function test_supportsInterface_success() public {
        // Arrange
        bytes4 erc165Selector = type(IERC165).interfaceId;
        bytes4 erc721Selector = type(IERC721Upgradeable).interfaceId;
        bytes4 mintableSelector = type(IMintable).interfaceId;

        // Act
        bool erc165Result = _asset.supportsInterface(erc165Selector);
        bool erc721Result = _asset.supportsInterface(erc721Selector);
        bool mintableResult = _asset.supportsInterface(mintableSelector);

        // Assert
        assertTrue(erc165Result && erc721Result && mintableResult);
    }

    function test_supportsInterface_interfaceNotSupported() public {
        // Arrange
        bytes4 selector = 0x0badc0d3;

        // Act
        bool result = _asset.supportsInterface(selector);

        // Assert
        assertFalse(result);
    }

    function testMintFor_HappyPath_Success() public {
        // Arrange
        address user_ = vm.addr(1);
        uint256 tokenId_ = 314;

        // Act
        vm.expectEmit(true, false, false, true);
        emit LogMintedERC721(user_, tokenId_);
        vm.prank(_starkEx());
        _asset.mintFor(user_, 1, abi.encode(tokenId_));

        // Assert
        assertEq(_asset.balanceOf(user_), 1);
        assertEq(_asset.ownerOf(tokenId_), user_);
    }

    function testMintFor_CallerNotStarkEx_RevertsWithError() public {
        // Arrange
        address user_ = vm.addr(1);
        uint256 tokenId_ = 314;
        address notStarkEx_ = vm.addr(8888);

        // Act + Assert
        vm.expectRevert(Mintable.NotAuthorizedError.selector);
        vm.prank(notStarkEx_);
        _asset.mintFor(user_, 1, abi.encode(tokenId_));
    }

    function testMintFor_InvalidQuantity_RevertsWithError() public {
        // Arrange
        address user_ = vm.addr(1);
        uint256 tokenId_ = 314;

        // Act + Assert
        vm.expectRevert(ERC721Mintable.InvalidMintAmountError.selector);
        vm.prank(_starkEx());
        _asset.mintFor(user_, 2, abi.encode(tokenId_));
    }

    function testMintFor_InvalidMintingBlob_RevertsWithError() public {
        // Arrange
        address user_ = vm.addr(1);

        // Act + Assert
        vm.expectRevert(ByteUtils.InvalidBytesLength.selector);
        vm.prank(_starkEx());
        _asset.mintFor(user_, 1, abi.encodePacked(uint8(42)));
    }

    function testMintFor_DuplicateId_RevertsWithError() public {
        // Arrange
        address user_ = vm.addr(1);
        uint256 tokenId_ = 314;
        // And
        vm.prank(_starkEx());
        _asset.mintFor(user_, 1, abi.encode(tokenId_));

        // Act
        vm.expectRevert(abi.encodePacked("ERC721: token already minted"));
        vm.prank(_starkEx());
        _asset.mintFor(user_, 1, abi.encode(tokenId_));

        // Assert
        assertEq(_asset.balanceOf(user_), 1);
        assertEq(_asset.ownerOf(tokenId_), user_);
    }

    //==============================================================================//
    //=== Internals                                                              ===//
    //==============================================================================//

    function _starkEx() private pure returns (address) {
        return vm.addr(12_345);
    }
}
