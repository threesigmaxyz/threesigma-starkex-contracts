//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC721Metadata } from "@openzeppelin/token/ERC721/extensions/IERC721Metadata.sol";

import { AccessControlLib } from "../../../../../src/modules/mintable/proxy/libraries/AccessControlLib.sol";
import { DeployERC721Impl } from "../../../../../src/modules/mintable/factory/implementations/erc721/DeployERC721Impl.sol";
import { IStarkEx } from "../../../../../src/modules/mintable/factory/interfaces/IStarkEx.sol";

import { TestFixture } from "../fixtures/TestFixture.sol";

contract DeployERC721ImplTest is TestFixture {
    //==============================================================================//
    //=== Events                                                                 ===//
    //==============================================================================//

    event LogDeployERC721Mintable(
        uint256 indexed id_, string name_, string symbol_, string uri_, address token_
    );

    //==============================================================================//
    //=== Constants                                                              ===//
    //==============================================================================//

    string private constant TOKEN_NAME = "Mintable ERC721 Token";
    string private constant TOKEN_SYMBOL = "M721T";
    string private constant TOKEN_URI = "https://starkexpress.io";

    //==============================================================================//
    //=== State Variables                                                        ===//
    //==============================================================================//

    DeployERC721Impl private _deployer;

    //==============================================================================//
    //=== SetUp                                                                  ===//
    //==============================================================================//

    function setUp() public override {
        super.setUp();
        _deployer = DeployERC721Impl(address(factory));
    }

    //==============================================================================//
    //=== Success Tests                                                          ===//
    //==============================================================================//

    function test_deployERC721_success() public {
        // Arrange
        uint256 deploymentId_ = 222;

        // Compute expected token deployment address.
        address expectedToken_ = _deployer.getERC721DeploymentAddress(deploymentId_);

        // Mock register call to StarkEx contract.
        vm.mockCall(_starkEx(), abi.encodeWithSelector(IStarkEx.registerToken.selector), "");

        // Setup expected event.
        vm.expectEmit(true, false, false, true);
        emit LogDeployERC721Mintable(
            deploymentId_,
            TOKEN_NAME,
            TOKEN_SYMBOL,
            TOKEN_URI,
            expectedToken_
        );

        // Act
        address token_ = _deployer.deployERC721(deploymentId_, TOKEN_NAME, TOKEN_SYMBOL, TOKEN_URI);

        // Assert
        assertEq(token_, expectedToken_);
        assertEq(IERC721Metadata(token_).name(), TOKEN_NAME);
        assertEq(IERC721Metadata(token_).symbol(), TOKEN_SYMBOL);
    }

    //==============================================================================//
    //=== Failure Tests                                                          ===//
    //==============================================================================//

    function test_deployERC721_notOwner() public {
        // Arrange
        uint256 deploymentId_ = 222;

        // Setup expected revert.
        vm.expectRevert(abi.encodeWithSelector(AccessControlLib.UnauthorizedError.selector));

        // Act + Assert
        vm.prank(vm.addr(987));
        _deployer.deployERC721(deploymentId_, TOKEN_NAME, TOKEN_SYMBOL, TOKEN_URI);
    }
}
