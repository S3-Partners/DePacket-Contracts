// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ERC6551Account} from "../src/ERC6551Account.sol";

contract ERC6551AccountScript is Script {
    ERC6551Account public account;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        account = new ERC6551Account();

        console.log("ERC6551Account deployed to:", address(account));

        vm.stopBroadcast();
    }
}
