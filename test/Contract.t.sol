// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Test } from "forge-std/Test.sol";

/// @dev See the "Writing Tests" section in the Foundry Book if this is your first time with Forge.
/// https://book.getfoundry.sh/forge/writing-tests
contract ContractTest is Test {
    function setUp() public {
        // solhint-disable-previous-line no-empty-blocks
    }

    /// @dev Run Forge with `-vvvv` to see console logs.
    function testExample() public {
        assertTrue(true);
    }
}
