// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import { Script } from "@forge-std/Script.sol";

import { Committee }        from "src/scalable-dex/committee/Committee.sol";
import { StarkExchange }    from "src/scalable-dex/starkex/StarkExchange.sol";
import { EscapeVerifier }   from "src/scalable-dex/starkex/components/EscapeVerifier.sol";
import { OrderRegistry }    from "src/scalable-dex/starkex/components/OrderRegistry.sol";
import { TokensAndRamping } from "src/scalable-dex/starkex/toplevel_subcontracts/TokensAndRamping.sol";
import { StarkExState }     from "src/scalable-dex/starkex/toplevel_subcontracts/StarkExState.sol";
import { ForcedActions }    from "src/scalable-dex/starkex/toplevel_subcontracts/ForcedActions.sol";
import { OnchainVaults }    from "src/scalable-dex/starkex/toplevel_subcontracts/OnchainVaults.sol";
import { ProxyUtils }       from "src/scalable-dex/starkex/toplevel_subcontracts/ProxyUtils.sol";
import { AllVerifiers }     from "src/scalable-dex/toplevel_subcontracts/AllVerifiers.sol";
import { Proxy }            from "src/scalable-dex/upgrade/Proxy.sol";

contract DeployStarkExScript is Script {
    function run() external {
        // record calls and contract creations made by our script contract
        vm.startBroadcast();

        /******************************************************************************************************************************/
        /*** Deploy Proxy                                                                                                           ***/
        /******************************************************************************************************************************/

        // deploy Proxy contract
        uint256 upgradeActivationDelay = 0;
        Proxy proxy = new Proxy(upgradeActivationDelay);

        /******************************************************************************************************************************/
        /*** Deploy DEX Implementation                                                                                              ***/
        /******************************************************************************************************************************/

        // deploy StarkExchange
        StarkExchange exchange = new StarkExchange();

        // deploy StarkExchange components
        AllVerifiers allVerifiers = new AllVerifiers();             // StarkWare_AllVerifiers_2022_2     (no init)
        TokensAndRamping tokensAndRamping = new TokensAndRamping(); // StarkWare_TokensAndRamping_2022_2 (no init)
        StarkExState starkExState = new StarkExState();             // StarkWare_StarkExState_2022_4     (init)
        ForcedActions forcedActions = new ForcedActions();          // StarkWare_ForcedActions_2022_2    (no init)
        OnchainVaults onchainVaults = new OnchainVaults();          // StarkWare_OnchainVaults_2022_2    (no init inconsistent impl)
        ProxyUtils proxyUtils = new ProxyUtils();                   // StarkWare_ProxyUtils_2022_2       (no init inconsistent impl)

        // deploy auxiliary contracts
        address[63] memory tables; // EscapeVerifier.N_TABLES = 63
        EscapeVerifier escapeVerifier = new EscapeVerifier(tables);

        /******************************************************************************************************************************/
        /*** Configure DEX                                                                                                          ***/
        /******************************************************************************************************************************/

        // configure implementation
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

        // stop recording calls
        vm.stopBroadcast();
    }

    /*
    TODO
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
    */
}
