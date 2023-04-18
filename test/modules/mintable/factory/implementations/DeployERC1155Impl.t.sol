//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC1155MetadataURI } from "@openzeppelin/token/ERC1155/extensions/IERC1155MetadataURI.sol";

import { ERC1155Mintable } from "../../../../../src/modules/mintable/erc1155/ERC1155Mintable.sol";
import { DeployERC1155Impl } from "../../../../../src/modules/mintable/factory/implementations/erc1155/DeployERC1155Impl.sol";
import { IStarkEx } from "../../../../../src/modules/mintable/factory/interfaces/IStarkEx.sol";
import { AccessControlLib } from "../../../../../src/modules/mintable/proxy/libraries/AccessControlLib.sol";

import { TestFixture } from "../fixtures/TestFixture.sol";

contract DeployERC1155ImplTest is TestFixture {
    //==============================================================================//
    //=== Events                                                                 ===//
    //==============================================================================//

    event LogDeployERC1155Mintable(
        uint256 indexed id_, string name_, string symbol_, string uri_, address token_
    );

    //==============================================================================//
    //=== Constants                                                              ===//
    //==============================================================================//

    string private constant TOKEN_NAME = "Mintable ERC71155 Token";
    string private constant TOKEN_SYMBOL = "M1155T";
    string private constant TOKEN_URI = "https://starkexpress.io";
    uint256 private constant TOKEN_QUANTUM = 10;

    //==============================================================================//
    //=== State Variables                                                        ===//
    //==============================================================================//

    DeployERC1155Impl private _deployer;

    //==============================================================================//
    //=== SetUp                                                                  ===//
    //==============================================================================//

    function setUp() public override {
        super.setUp();
        _deployer = DeployERC1155Impl(address(factory));
    }

    //==============================================================================//
    //=== Success Tests                                                          ===//
    //==============================================================================//

    function test_deployERC1155_success() public {
        // Arrange
        uint256 deploymentId_ = 222;

        // Compute expected token deployment address.
        address expectedToken_ = _deployer.getERC1155DeploymentAddress(deploymentId_);

        // Mock register call to StarkEx contract.
        vm.mockCall(_starkEx(), abi.encodeWithSelector(IStarkEx.registerToken.selector), "");

        // Setup expected event.
        vm.expectEmit(true, false, false, true);
        emit LogDeployERC1155Mintable(
            deploymentId_,
            TOKEN_NAME,
            TOKEN_SYMBOL,
            TOKEN_URI,
            expectedToken_
        );

        // Act
        address token_ = _deployer.deployERC1155(deploymentId_, TOKEN_NAME, TOKEN_SYMBOL, TOKEN_URI, TOKEN_QUANTUM);

        // Assert
        assertEq(token_, expectedToken_);
        assertEq(ERC1155Mintable(token_).name(), TOKEN_NAME);
        assertEq(ERC1155Mintable(token_).symbol(), TOKEN_SYMBOL);
        assertEq(IERC1155MetadataURI(token_).uri(1), TOKEN_URI);
    }

    //==============================================================================//
    //=== Failure Tests                                                          ===//
    //==============================================================================//

    function test_deployERC1155_notOwner() public {
        // Arrange
        uint256 deploymentId_ = 222;

        // Setup expected revert.
        vm.expectRevert(abi.encodeWithSelector(AccessControlLib.UnauthorizedError.selector));

        // Act + Assert
        vm.prank(vm.addr(987));
        _deployer.deployERC1155(deploymentId_, TOKEN_NAME, TOKEN_SYMBOL, TOKEN_URI, TOKEN_QUANTUM);
    }
}
