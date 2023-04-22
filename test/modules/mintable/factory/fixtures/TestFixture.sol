//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "@forge-std/Test.sol";

import { ProxyUpgradeLib } from "../../../../../src/modules/mintable/proxy/libraries/ProxyUpgradeLib.sol";
import { ProxyUpgradeImpl } from "../../../../../src/modules/mintable/proxy/implementations/ProxyUpgradeImpl.sol";
import { TokenFactory } from "../../../../../src/modules/mintable/factory/TokenFactory.sol";
import { DeployERC20Impl } from "../../../../../src/modules/mintable/factory/implementations/erc20/DeployERC20Impl.sol";
import { DeployERC721Impl } from "../../../../../src/modules/mintable/factory/implementations/erc721/DeployERC721Impl.sol";
import { DeployERC1155Impl } from "../../../../../src/modules/mintable/factory/implementations/erc1155/DeployERC1155Impl.sol";

contract TestFixture is Test {
    //==============================================================================//
    //=== Constants                                                              ===//
    //==============================================================================//

    uint256 private constant STARKEX_ADDRESS_ID = 1337;

    //==============================================================================//
    //=== State Variables                                                        ===//
    //==============================================================================//

    TokenFactory public factory;

    //==============================================================================//
    //=== Fixture Setup                                                          ===//
    //==============================================================================//

    function setUp() public virtual {
        // Deploy token factory dispatcher.
        factory = new TokenFactory();

        // Deploy implementations.
        address deployERC20Impl_ = address(new DeployERC20Impl(_starkEx()));
        address deployERC721Impl_ = address(new DeployERC721Impl(_starkEx()));
        address deployERC1155Impl_ = address(new DeployERC1155Impl(_starkEx()));

        // Register implementations in the factory dispatcher.
        bytes4[] memory deployERC20Selectors_ = new bytes4[](2);
        deployERC20Selectors_[0] = DeployERC20Impl.deployERC20.selector;
        deployERC20Selectors_[1] = DeployERC20Impl.getERC20DeploymentAddress.selector;
        ProxyUpgradeImpl(address(factory)).upgradeProxy(
            ProxyUpgradeLib.Upgrade({
                action: ProxyUpgradeLib.ProxyUpgradeAction.Register,
                implementation: deployERC20Impl_,
                selectors: deployERC20Selectors_
            }),
            address(0),
            ""
        );

        bytes4[] memory deployERC721Selectors_ = new bytes4[](2);
        deployERC721Selectors_[0] = DeployERC721Impl.deployERC721.selector;
        deployERC721Selectors_[1] = DeployERC721Impl.getERC721DeploymentAddress.selector;
        ProxyUpgradeImpl(address(factory)).upgradeProxy(
            ProxyUpgradeLib.Upgrade({
                action: ProxyUpgradeLib.ProxyUpgradeAction.Register,
                implementation: deployERC721Impl_,
                selectors: deployERC721Selectors_
            }),
            address(0),
            ""
        );

        bytes4[] memory deployERC1155Selectors_ = new bytes4[](2);
        deployERC1155Selectors_[0] = DeployERC1155Impl.deployERC1155.selector;
        deployERC1155Selectors_[1] = DeployERC1155Impl.getERC1155DeploymentAddress.selector;
        ProxyUpgradeImpl(address(factory)).upgradeProxy(
            ProxyUpgradeLib.Upgrade({
                action: ProxyUpgradeLib.ProxyUpgradeAction.Register,
                implementation: deployERC1155Impl_,
                selectors: deployERC1155Selectors_
            }),
            address(0),
            ""
        );
    }

    //==============================================================================//
    //=== Internal Test Helpers                                                  ===//
    //==============================================================================//

    function _starkEx() internal pure returns (address) {
        return vm.addr(STARKEX_ADDRESS_ID);
    }
}
