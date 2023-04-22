//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Script } from "@forge-std/Script.sol";

import { TokenFactory } from "../../src/modules/mintable/factory/TokenFactory.sol";
import { DeployERC20Impl } from "../../src/modules/mintable/factory/implementations/erc20/DeployERC20Impl.sol";
import { DeployERC721Impl } from "../../src/modules/mintable/factory/implementations/erc721/DeployERC721Impl.sol";
import { DeployERC1155Impl } from "../../src/modules/mintable/factory/implementations/erc1155/DeployERC1155Impl.sol";
import { ProxyUpgradeLib } from "../../src/modules/mintable/proxy/libraries/ProxyUpgradeLib.sol";
import { ProxyUpgradeImpl } from "../../src/modules/mintable/proxy/implementations/ProxyUpgradeImpl.sol";

contract DeployMintableModuleScript is Script {
    string public constant MERC20_NAME = "Three Sigma MERC20 Token";
    string public constant MERC20_SYMBOL = "TSTME20";
    uint256 public constant MERC20_QUANTUM = 10_000;

    string public constant MERC721_NAME = "Three Sigma MERC721 Token";
    string public constant MERC721_SYMBOL = "TSTME721";
    string public constant MERC721_URI = "https://tstme721.starkexpress.io";

    string public constant MERC1155_NAME = "Three Sigma MERC1155 Token";
    string public constant MERC1155_SYMBOL = "TSTME1155";
    string public constant MERC1155_URI = "https://tstme1155.starkexpress.io";
    uint256 public constant MERC1155_QUANTUM = 1;

    address private _starkEx;

    function setUp() public {
        _starkEx = vm.envAddress("SCALABLE_DEX_ADDRESS");
    }

    function run() external {
        // record calls and contract creations made by our script contract
        vm.startBroadcast();

        // Deploy token factory dispatcher.
        TokenFactory factory_ = new TokenFactory();

        // Deploy implementations.
        address deployERC20Impl_ = address(new DeployERC20Impl(_starkEx));
        address deployERC721Impl_ = address(new DeployERC721Impl(_starkEx));
        address deployERC1155Impl_ = address(new DeployERC1155Impl(_starkEx));

        // Register implementations in the factory dispatcher.
        bytes4[] memory deployERC20Selectors_ = new bytes4[](2);
        deployERC20Selectors_[0] = DeployERC20Impl.deployERC20.selector;
        deployERC20Selectors_[1] = DeployERC20Impl.getERC20DeploymentAddress.selector;
        ProxyUpgradeImpl(address(factory_)).upgradeProxy(
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
        ProxyUpgradeImpl(address(factory_)).upgradeProxy(
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
        ProxyUpgradeImpl(address(factory_)).upgradeProxy(
            ProxyUpgradeLib.Upgrade({
                action: ProxyUpgradeLib.ProxyUpgradeAction.Register,
                implementation: deployERC1155Impl_,
                selectors: deployERC1155Selectors_
            }),
            address(0),
            ""
        );

        // Deploy mintable tokens.
        DeployERC20Impl(address(factory_)).deployERC20(1, MERC20_NAME, MERC20_SYMBOL, MERC20_QUANTUM);
        DeployERC721Impl(address(factory_)).deployERC721(2, MERC721_NAME, MERC721_SYMBOL, MERC721_URI);
        // TODO enable in StarkEx V5
        // DeployERC1155Impl(address(factory_)).deployERC1155(3, MERC1155_NAME, MERC1155_SYMBOL, MERC1155_URI, MERC1155_QUANTUM);

        // stop recording calls
        vm.stopBroadcast();
    }
}
