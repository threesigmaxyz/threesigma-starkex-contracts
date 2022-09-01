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

    function run() external {
        // record calls and contract creations made by our script contract
        vm.startBroadcast();

        _deployProxy();
        _deployStarkExchange();
        _deployAuxContracts();

        _initProxy();

        // TODO _deployDataAvailabilityCommittee();

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
}
