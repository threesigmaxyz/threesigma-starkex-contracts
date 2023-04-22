//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC20Metadata } from "@openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";

import { AccessControlLib } from "../../../../../src/modules/mintable/proxy/libraries/AccessControlLib.sol";
import { DeployERC20Impl } from "../../../../../src/modules/mintable/factory/implementations/erc20/DeployERC20Impl.sol";
import { IStarkEx } from "../../../../../src/modules/mintable/factory/interfaces/IStarkEx.sol";

import { TestFixture } from "../fixtures/TestFixture.sol";

contract DeployERC20ImplTest is TestFixture {
    //==============================================================================//
    //=== Events                                                                 ===//
    //==============================================================================//

    event LogDeployERC20Mintable(uint256 indexed id_, string name_, string symbol_, address token_);

    //==============================================================================//
    //=== Constants                                                              ===//
    //==============================================================================//

    string private constant TOKEN_NAME = "Mintable ERC20 Token";
    string private constant TOKEN_SYMBOL = "M20T";
    uint256 private constant TOKEN_QUANTUM = 1_000_000;

    //==============================================================================//
    //=== State Variables                                                        ===//
    //==============================================================================//

    DeployERC20Impl private _deployer;

    //==============================================================================//
    //=== SetUp                                                                  ===//
    //==============================================================================//

    function setUp() public override {
        super.setUp();
        _deployer = DeployERC20Impl(address(factory));
    }

    //==============================================================================//
    //=== Success Tests                                                          ===//
    //==============================================================================//

    function test_deployERC20_success() public {
        // Arrange
        uint256 deploymentId_ = 222;

        // Compute expected token deployment address.
        address expectedToken_ = _deployer.getERC20DeploymentAddress(deploymentId_);

        // Mock register call to StarkEx contract.
        vm.mockCall(_starkEx(), abi.encodeWithSelector(IStarkEx.registerToken.selector), "");

        // Setup expected event.
        vm.expectEmit(true, false, false, true);
        emit LogDeployERC20Mintable(
            deploymentId_,
            TOKEN_NAME,
            TOKEN_SYMBOL,
            expectedToken_
        );

        // Act
        address token_ = _deployer.deployERC20(deploymentId_, TOKEN_NAME, TOKEN_SYMBOL, TOKEN_QUANTUM);

        // Assert
        assertEq(token_, expectedToken_);
        assertEq(IERC20Metadata(token_).name(), TOKEN_NAME);
        assertEq(IERC20Metadata(token_).symbol(), TOKEN_SYMBOL);
    }

    //==============================================================================//
    //=== Failure Tests                                                          ===//
    //==============================================================================//

    function test_deployERC20_notOwner() public {
        // Arrange
        uint256 deploymentId_ = 222;

        // Setup expected revert.
        vm.expectRevert(abi.encodeWithSelector(AccessControlLib.UnauthorizedError.selector));

        // Act + Assert
        vm.prank(vm.addr(987));
        _deployer.deployERC20(deploymentId_, TOKEN_NAME, TOKEN_SYMBOL, TOKEN_QUANTUM);
    }
}
