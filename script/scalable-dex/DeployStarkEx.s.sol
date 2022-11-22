// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import { Script }              from "@forge-std-legacy/Script.sol";
import { console2 as Console } from "@forge-std-legacy/console2.sol";

import { Committee }        from "src/scalable-dex/committee/Committee.sol";
import { TokenRegister }    from "src/scalable-dex/components/TokenRegister.sol";
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

    string constant STARKEX_SEQUENCE_NUMBER = "STARKEX_SEQUENCE_NUMBER";
    string constant STARKEX_VALIDIUM_VAULT_ROOT = "STARKEX_VALIDIUM_VAULT_ROOT";
    string constant STARKEX_ROLLUP_VAULT_ROOT = "STARKEX_ROLLUP_VAULT_ROOT";
    string constant STARKEX_ORDER_ROOT = "STARKEX_ORDER_ROOT";
    string constant STARKEX_VALIDIUM_TREE_HEIGHT = "STARKEX_VALIDIUM_TREE_HEIGHT";
    string constant STARKEX_ROLLUP_TREE_HEIGHT = "STARKEX_ROLLUP_TREE_HEIGHT";
    string constant STARKEX_ORDER_TREE_HEIGHT = "STARKEX_ORDER_TREE_HEIGHT";
    string constant STARKEX_STRICT_VAULT_BALANCE_POLICY = "STARKEX_STRICT_VAULT_BALANCE_POLICY";

    string constant STARKEX_TOKEN_ADMIN = "STARKEX_TOKEN_ADMIN";

    EscapeVerifier escapeVerifier;
    OrderRegistry orderRegistry;

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
        escapeVerifier = new EscapeVerifier(tables);
        orderRegistry = new OrderRegistry();

        /******************************************************************************************************************************/
        /*** Configure DEX                                                                                                          ***/
        /******************************************************************************************************************************/

        {
            // get state root initialization data
            bytes memory stateRootInitializationData_ = getStateUpdateInitData(
                address(escapeVerifier), address(orderRegistry));

            // configure implementation
            bytes memory initializationData = abi.encode(
                address(allVerifiers),
                address(tokensAndRamping),
                address(starkExState),
                address(forcedActions),
                address(onchainVaults),
                address(proxyUtils),
                address(0x0) // TODO External initializer contract address
            );
            initializationData = abi.encodePacked(initializationData, stateRootInitializationData_);

            // add implementation to timelocked queue
            proxy.addImplementation(address(exchange), initializationData, false);
            // upgrade immediately since timelock delay is 0
            proxy.upgradeTo(address(exchange), initializationData, false);
        }
        

        /******************************************************************************************************************************/
        /*** Deploy Data Availability Committee                                                                                     ***/
        /******************************************************************************************************************************/

        _deployDataAvailabilityCommittee();

        /******************************************************************************************************************************/
        /*** Governance Operations                                                                                                  ***/
        /******************************************************************************************************************************/
        
        address tokenAdmin = vm.envAddress(STARKEX_TOKEN_ADMIN);
        if (tokenAdmin != address(0)) {
            TokenRegister(address(proxy)).registerTokenAdmin(tokenAdmin);
        }
        Console.log(tokenAdmin);

        // stop recording calls
        vm.stopBroadcast();
    }

    /// @dev deploy data availabigetStateUpdateInitData()lity committee contract
    function _deployDataAvailabilityCommittee() internal returns (address) {
        // load DA threshold from env
        uint256 numSignaturesRequired_ = vm.envUint("STARKEX_DA_THRESHOLD");
        if (numSignaturesRequired_ == 0) {
            return address(0);
        }

        // load DA members from env
        address[] memory committeeMembers_ = vm.envAddress("STARKEX_DA_COMMITTEE", ",");

        // validate settings
        require(committeeMembers_.length >= numSignaturesRequired_, "STARKEX:DDAC:OUT_OF_BOUNDS");

        // deploy committee contract
        Committee committee = new Committee(committeeMembers_, numSignaturesRequired_);
        
        return address(committee);
    }

    function getStateUpdateInitData(
        address escapeVerifierAddress_,
        address orderRegistryAddress_
    ) private returns (bytes memory) {
        // encode init data
        return abi.encode(
            1337,
            escapeVerifierAddress_,
            vm.envUint(STARKEX_SEQUENCE_NUMBER),
            vm.envUint(STARKEX_VALIDIUM_VAULT_ROOT),
            vm.envUint(STARKEX_ROLLUP_VAULT_ROOT),
            vm.envUint(STARKEX_ORDER_ROOT),
            vm.envUint(STARKEX_VALIDIUM_TREE_HEIGHT),
            vm.envUint(STARKEX_ROLLUP_TREE_HEIGHT),
            vm.envUint(STARKEX_ORDER_TREE_HEIGHT),
            vm.envBool(STARKEX_STRICT_VAULT_BALANCE_POLICY),
            orderRegistryAddress_
        );
    }
}
