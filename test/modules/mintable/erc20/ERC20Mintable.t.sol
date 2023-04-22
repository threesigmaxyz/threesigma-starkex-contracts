//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC165 } from "@openzeppelin/interfaces/IERC165.sol";
import { Test } from "forge-std/Test.sol";

import { IMintable } from "../../../../src/modules/mintable/core/IMintable.sol";
import { ERC20Mintable } from "../../../../src/modules/mintable/erc20/ERC20Mintable.sol";

contract ERC20MintableTest is Test {
    string private constant NAME = "Three Sigma MERC20 Token";
    string private constant SYMBOL = "TSTME20";

    error NotAuthorizedError();
    error InvalidMintAmountError();

    event LogMintedERC20(address indexed to_, uint256 amount_);

    ERC20Mintable private _asset;

    function setUp() public {
        _asset = new ERC20Mintable();
        _asset.initialize(NAME, SYMBOL, _starkEx());
    }

    function test_constructor() public {
        // Assert
        assertEq(_asset.name(), NAME);
        assertEq(_asset.symbol(), SYMBOL);
        assertEq(_asset.starkEx(), _starkEx());
    }

    function test_supportsInterface_success() public {
        // Arrange
        bytes4 erc165Selector = type(IERC165).interfaceId;
        bytes4 mintableSelector = type(IMintable).interfaceId;

        // Act
        bool erc165Result = _asset.supportsInterface(erc165Selector);
        bool mintableResult = _asset.supportsInterface(mintableSelector);

        // Assert
        assertTrue(erc165Result && mintableResult);
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
        uint256 quantity_ = 314_159_265;

        // Act
        vm.expectEmit(true, false, false, true);
        emit LogMintedERC20(user_, quantity_);
        vm.prank(_starkEx());
        _asset.mintFor(user_, quantity_, "");

        // Assert
        assertEq(_asset.totalSupply(), quantity_);
        assertEq(_asset.balanceOf(user_), quantity_);
    }

    function testMintFor_CallerNotStarkEx_RevertsWIthError() public {
        // Arrange
        address user_ = vm.addr(1);
        uint256 quantity_ = 314_159_265;
        address notStarkEx_ = vm.addr(8888);

        // Act
        vm.expectRevert(NotAuthorizedError.selector);
        vm.prank(notStarkEx_);
        _asset.mintFor(user_, quantity_, "");
    }

    function testMintFor_InvalidQuantity_RevertsWIthError() public {
        // Arrange
        address user_ = vm.addr(1);

        // Act
        vm.expectRevert(InvalidMintAmountError.selector);
        vm.prank(_starkEx());
        _asset.mintFor(user_, 0, "");
    }

    function _starkEx() private pure returns (address) {
        return vm.addr(12_345);
    }
}
