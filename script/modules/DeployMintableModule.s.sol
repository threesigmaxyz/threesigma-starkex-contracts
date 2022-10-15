//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Script } from "@forge-std/Script.sol";

import { ERC20Mintable }  from "src/modules/mintable/ERC20/ERC20Mintable.sol";
import { ERC721Mintable } from "src/modules/mintable/ERC721/ERC721Mintable.sol";

contract DeployMintableModuleScript is Script {
    string public constant MERC20_NAME = "Three Sigma MERC20 Token";
    string public constant MERC20_SYMBOL = "TSTME20";

    string public constant MERC721_NAME = "Three Sigma MERC721 Token";
    string public constant MERC721_SYMBOL = "TSTME721";

    address public operator;

    function setUp() public {
        operator = vm.envAddress("SCALABLE_DEX_ADDRESS");
    }

    function run() external {
        address operator_ = vm.envAddress("SCALABLE_DEX_ADDRESS");

        // record calls and contract creations made by our script contract
        vm.startBroadcast();

        // deploy Mintable Erc20 Token contract
        new ERC20Mintable(MERC20_NAME, MERC20_SYMBOL, operator_);

        // deploy Mintable Erc721 Token contracts
        new ERC721Mintable(MERC721_NAME, MERC721_SYMBOL, operator_);

        // stop recording calls
        vm.stopBroadcast();
    }
}
