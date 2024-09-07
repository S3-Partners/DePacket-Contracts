// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {RedPacketNFT} from "../src/RedPacketNFT.sol";

contract RedPacketNFTScript is Script {
    RedPacketNFT public nft;

    function setUp() public {}

    function run() public {

        vm.startBroadcast();

        nft = new RedPacketNFT();

        console.log("RedPacketNFT deployed to:", address(nft));

        vm.stopBroadcast();
    }
}
