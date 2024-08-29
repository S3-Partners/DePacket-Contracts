// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {RedPacketDistributor} from "../src/RedPacketDistributor.sol";

contract RedPacketDistributorScript is Script {
    RedPacketDistributor public redpacketdistributor;
    uint256 public subscriptionId;

    function setUp() public {
        subscriptionId = vm.envUint("SUBSCRIPTIONID");
    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        redpacketdistributor = new RedPacketDistributor(subscriptionId);

        console.log("RedPacketDistributor deployed to:", address(redpacketdistributor));

        vm.stopBroadcast();
    }
}
