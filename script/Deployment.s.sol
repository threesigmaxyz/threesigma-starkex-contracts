// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "forge-std/Script.sol";

import "src/upgrade/Proxy.sol";

import "src/committee/Committee.sol";

import "src/starkex/StarkExchange.sol";
import "src/toplevel_subcontracts/AllVerifiers.sol";
import "src/starkex/toplevel_subcontracts/TokensAndRamping.sol";
import "src/starkex/toplevel_subcontracts/StarkExState.sol";
import "src/starkex/toplevel_subcontracts/ForcedActions.sol";
import "src/starkex/toplevel_subcontracts/OnchainVaults.sol";
import "src/starkex/toplevel_subcontracts/ProxyUtils.sol";

import "src/starkex/components/EscapeVerifier.sol";
import "src/starkex/components/OrderRegistry.sol";

import "src/tokens/Mintable/MintableERC20Asset.sol";
import "src/tokens/Mintable/MintableERC721Asset.sol";

contract DeploymentScript is Script {
    // Main StarkEx Exchange Dispatcher
    StarkExchange exchange;

    // StarkEx Exchange Top Level Components
    AllVerifiers allVerifiers; // StarkWare_AllVerifiers_2022_2
    TokensAndRamping tokensAndRamping; // StarkWare_TokensAndRamping_2022_2
    StarkExState starkExState; // StarkWare_StarkExState_2022_4
    ForcedActions forcedActions; // StarkWare_ForcedActions_2022_2
    OnchainVaults onchainVaults; // StarkWare_OnchainVaults_2022_2
    ProxyUtils proxyUtils; // StarkWare_ProxyUtils_2022_2

    // Aux Contracts
    EscapeVerifier escapeVerifier;
    OrderRegistry orderRegistry;

    // Proxy Contract
    Proxy proxy;

    // Tokens
    MintableERC20Asset mintableErc20Asset;
    MintableERC721Asset mintableErc721Asset;

    function run() external {
        // record calls and contract creations made by our script contract
        vm.startBroadcast();

        _deployProxy();
        _deployStarkExchange();
        _deployAuxContracts();

        _initProxy();

        // TODO _deployDataAvailabilityCommittee();

        // deploy token contracts
        _deployMintableErc20Contracts();
        _deployMintableErc721Contracts();

        // stop recording calls
        vm.stopBroadcast();
    }

    /// @dev deploy StarkExchange and configure dispatcher
    function _deployStarkExchange() internal {
        // deploy exchange
        exchange = new StarkExchange();

        // deploy exchange components
        allVerifiers = new AllVerifiers(); // StarkWare_AllVerifiers_2022_2 (no init)
        tokensAndRamping = new TokensAndRamping(); // StarkWare_TokensAndRamping_2022_2 (no init)
        starkExState = new StarkExState(); // StarkWare_StarkExState_2022_4 (init)
        forcedActions = new ForcedActions(); // StarkWare_ForcedActions_2022_2 (no init)
        onchainVaults = new OnchainVaults(); // StarkWare_OnchainVaults_2022_2 (no init inconsistent impl)
        proxyUtils = new ProxyUtils(); // StarkWare_ProxyUtils_2022_2 (no init inconsistent impl)
    }

    /// @dev deploy auxiliary contracts
    function _deployAuxContracts() internal {
        /**
        An escapeVerifier verifies that the contents of a vault belong to a certain Merkle commitment (root).
        Allows for users to withdraw from a frozen exchange.
        */
        address[63] memory tables; // EscapeVerifier.N_TABLES = 63
        escapeVerifier = new EscapeVerifier(tables);
    }

    /// @dev deploy Proxy contract
    function _deployProxy() internal {
        uint256 upgradeActivationDelay = 0;
        proxy = new Proxy(upgradeActivationDelay);
    }

    /// @dev deploy Proxy contract
    function _initProxy() internal {
        // set implementation pointing to StarkExchange
        // initialization must contain byte array containning addresses for all 6 components in the following order:
        // 1. StarkWare_AllVerifiers_2022_2
        // 2. StarkWare_TokensAndRamping_2022_2
        // 3. StarkWare_StarkExState_2022_4
        // 4. StarkWare_ForcedActions_2022_2
        // 5. StarkWare_OnchainVaults_2022_2
        // 6. StarkWare_ProxyUtils_2022_2
        // additionaly extra data can be passed ncluding:
        // 7. External initializer contract address
        // 8. Initialization data

        // configure dispatcher
        bytes memory initializationData = abi.encode(
            address(allVerifiers),
            address(tokensAndRamping),
            address(starkExState),
            address(forcedActions),
            address(onchainVaults),
            address(proxyUtils),
            address(0x0) // TODO External initializer contract address
            // TODO starkExState init data
            // starkExState init struct contains: 2 * address + 8 * uint256 + 1 * bool = 352 bytes.
        );

        // add implementation to timelocked queue
        proxy.addImplementation(address(exchange), initializationData, false);
        // upgrade immediately since timelock delay is 0
        proxy.upgradeTo(address(exchange), initializationData, false);
    }

    /// @dev deploy data availability committee contract
    function _deployDataAvailabilityCommittee() internal {
        // list of availability committee members.
        address[] memory committeeMembers = new address[](3);
        committeeMembers[0] = 0xa342f5D851E866E18ff98F351f2c6637f4478dB5;
        committeeMembers[1] = 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045;
        committeeMembers[2] = 0x19A1FCD731895cb0F2BE59f21Eabd8D1893A4DBE;

        // deploy committee contract
        Committee committee = new Committee(committeeMembers, 2);
    }

    /// @dev deploy Mintable Erc20 Tokens contracts
    function _deployMintableErc20Contracts() internal {
        // TODO Any way of not having these addresses hardcoded? Maybe only deploying the contracts after having the chained deployed with anvil
        address owner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        string memory name = "Three Sigma MERC20 Token";
        string memory symbol = "TSTME20";
        // TODO The operator address is not the same as the StarkExContractAddress right? We need to deploy the operator contract as well right?
        address operator = 0x5FbDB2315678afecb367f032d93F642f64180aa3;

        mintableErc20Asset = new MintableERC20Asset(owner, name, symbol, operator);
    }

    /// @dev deploy Mintable Erc721 Tokens contracts
    function _deployMintableErc721Contracts() internal {
        address owner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        string memory name = "Three Sigma MERC721 Token";
        string memory symbol = "TSTME721";
        address operator = 0x5FbDB2315678afecb367f032d93F642f64180aa3;

        mintableErc721Asset = new MintableERC721Asset(owner, name, symbol, operator);
    }
}
