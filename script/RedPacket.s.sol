// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {RedPacket} from "../src/RedPacket.sol";

contract RedPacketScript is Script {
    RedPacket public redpacket;
    address public factory;

    function setUp() public {
        factory = 0x7eA36391c7127A7f40E5c23212A8016d6E494546;
    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        redpacket = new RedPacket(factory);

        console.log("RedPacket deployed to:", address(redpacket));

        vm.stopBroadcast();
    }
}
