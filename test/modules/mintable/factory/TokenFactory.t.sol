//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC20Metadata } from "@openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";
import { Test } from "forge-std/Test.sol";

import { TokenFactory } from "../../../../src/modules/mintable/factory/TokenFactory.sol";
import { IStarkEx } from "../../../../src/modules/mintable/factory/interfaces/IStarkEx.sol";

contract TokenFactoryTest is Test {
    address private _starkEx;
    TokenFactory private _factory;

    function setUp() public {
        _starkEx = vm.addr(1337);
        _factory = new TokenFactory();
    }

    /*function test_deployERC20_success() public {
        // Arrange
        uint256 id_ = 222;
        string memory name_ = "ThreeSigma Token 20";
        string memory symbol_ = "TST20";
        uint256 quantum_ = 1_000_000;
        
        // compute expected token deployment address
        address expectedToken_ = _factory.getERC20DeploymentAddress(id_, name_, symbol_);

        // mock register call to StarkEx contract
        vm.mockCall(
            _starkEx,
            abi.encodeWithSelector(IStarkEx.registerToken.selector),
            ""
        );

        // Act
        address token_ = _factory.deployERC20(id_, name_, symbol_, quantum_);
        
        // Assert
        assertEq(token_, expectedToken_);
        assertEq(IERC20Metadata(token_).name(), name_);
        assertEq(IERC20Metadata(token_).symbol(), symbol_);
        // TODO decimals+ totalSupply? assertEq(IERC20Metadata(token_).symbol(), symbol_);
    }*/

    function test_deployERC20_notOwner() public {
        // Arrange
        // TODO

        // Act
        // TODO

        // Assert
        // TODO
    }

    function test_deployERC721_success() public {
        // TODO
    }

    function test_deployERC1155_success() public {
        // TODO
    }

    // TODO what if there is already a deployed token for that ID?
    // TODO check issues with quantum and token decimals...
}
