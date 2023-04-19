//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC165 } from "@openzeppelin/interfaces/IERC165.sol";
import { IERC1155Upgradeable } from "@openzeppelin-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import { Test } from "forge-std/Test.sol";

import { IMintable } from "../../../../src/modules/mintable/core/IMintable.sol";
import { Mintable } from "../../../../src/modules/mintable/core/Mintable.sol";
import { ERC1155Mintable } from "../../../../src/modules/mintable/erc1155/ERC1155Mintable.sol";
import { ByteUtils } from "../../../../src/modules/mintable/utils/ByteUtils.sol";

contract ERC1155MintableTest is Test {
    //==============================================================================//
    //=== Events                                                                 ===//
    //==============================================================================//

    event LogMintedERC1155(address indexed to_, uint256 tokenId_, uint256 amount_);

    //==============================================================================//
    //=== Constants                                                              ===//
    //==============================================================================//

    string private constant NAME = "Three Sigma MERC1155 Token";
    string private constant SYMBOL = "TSTME1155";
    string private constant URI = "https://starkexpress.io/";

    //==============================================================================//
    //=== State Variables                                                        ===//
    //==============================================================================//

    ERC1155Mintable private _asset;

    //==============================================================================//
    //=== SetUp                                                                  ===//
    //==============================================================================//

    function setUp() public {
        _asset = new ERC1155Mintable();
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
        bytes4 erc1155Selector = type(IERC1155Upgradeable).interfaceId;
        bytes4 mintableSelector = type(IMintable).interfaceId;

        // Act
        bool erc165Result = _asset.supportsInterface(erc165Selector);
        bool erc1155Result = _asset.supportsInterface(erc1155Selector);
        bool mintableResult = _asset.supportsInterface(mintableSelector);

        // Assert
        assertTrue(erc165Result && erc1155Result && mintableResult);
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
        uint256 amount_ = 1337;

        // Act
        vm.expectEmit(true, false, false, true);
        emit LogMintedERC1155(user_, tokenId_, amount_);
        vm.prank(_starkEx());
        _asset.mintFor(user_, amount_, abi.encode(tokenId_));

        // Assert
        assertEq(_asset.balanceOf(user_, tokenId_), amount_);
    }

    function testMintFor_CallerNotStarkEx_RevertsWithError() public {
        // Arrange
        address user_ = vm.addr(1);
        uint256 tokenId_ = 314;
        uint256 amount_ = 1337;
        address notStarkEx_ = vm.addr(8888);

        // Act + Assert
        vm.expectRevert(Mintable.NotAuthorizedError.selector);
        vm.prank(notStarkEx_);
        _asset.mintFor(user_, amount_, abi.encode(tokenId_));
    }

    function testMintFor_InvalidQuantity_RevertsWithError() public {
        // Arrange
        address user_ = vm.addr(1);
        uint256 tokenId_ = 314;

        // Act + Assert
        vm.expectRevert(ERC1155Mintable.InvalidMintAmountError.selector);
        vm.prank(_starkEx());
        _asset.mintFor(user_, 0, abi.encode(tokenId_));
    }

    function testMintFor_InvalidMintingBlob_RevertsWithError() public {
        // Arrange
        address user_ = vm.addr(1);
        uint256 amount_ = 1337;

        // Act + Assert
        vm.expectRevert(ByteUtils.InvalidBytesLength.selector);
        vm.prank(_starkEx());
        _asset.mintFor(user_, amount_, abi.encodePacked(uint8(42)));
    }

    //==============================================================================//
    //=== Internals                                                              ===//
    //==============================================================================//

    function _starkEx() private pure returns (address) {
        return vm.addr(12_345);
    }
}
