//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Script } from "@forge-std/Script.sol";

import {ERC20Faucet} from "src/modules/faucet/ERC20/ERC20Faucet.sol";
import {ERC721Faucet} from "src/modules/faucet/ERC721/ERC721Faucet.sol";
import {ERC1155Faucet} from "src/modules/faucet/ERC1155/ERC1155Faucet.sol";

contract DeployFaucetsModuleScript is Script {
    string public constant ERC20_NAME = "Three Sigma ERC20 Token";
    string public constant ERC20_SYMBOL = "TSTE20";

    string public constant ERC721_NAME = "Three Sigma ERC721 Token";
    string public constant ERC721_SYMBOL = "TSTE721";

    string public constant ERC1155_NAME = "Three Sigma ERC1155 Token";
    string public constant ERC1155_SYMBOL = "TSTE1155";

    address public faucet;

    function setUp() public {
        faucet = vm.envAddress("FAUCET_ADDRESS");
    }

    function run() external {
        address faucet_ = vm.envAddress("FAUCET_ADDRESS");

        // record calls and contract creations made by our script contract
        vm.startBroadcast();

        // Deploy Erc20 Token Faucet contract
        new ERC20Faucet(ERC20_NAME, ERC20_SYMBOL, faucet_);

        // Deploy Erc721 Token Faucet contract
        new ERC721Faucet(ERC721_NAME, ERC721_SYMBOL, faucet_);

        // Deploy Erc1155 Token Faucet contract
        new ERC1155Faucet("https://threesigma.xyz/", faucet_);

        // stop recording calls
        vm.stopBroadcast();
    }
}
