// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ERC6551Registry} from "../src/ERC6551Registry.sol";

contract ERC6551RegistryScript is Script {
    ERC6551Registry public registry;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        registry = new ERC6551Registry();

        console.log("ERC6551Registry deployed to:", address(registry));

        vm.stopBroadcast();
    }
}
