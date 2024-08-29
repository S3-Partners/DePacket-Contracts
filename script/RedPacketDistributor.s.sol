// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {RedPacketDistributor} from "../src/RedPacketDistributor.sol";

contract RedPacketDistributorScript is Script {
    RedPacketDistributor public redpacketdistributor;
    address vrfCoordinator;
    uint256 subscriptionId;
    bytes32 keyHash;
    uint32 callbackGasLimit;
    uint16 requestConfirmations;
    uint32 numWords;

    function setUp() public {
        subscriptionId = vm.envUint("SUBSCRIPTIONID");
        vrfCoordinator = vm.envAddress("VRFCOORDINATOR");
        keyHash = vm.envBytes32("KEYHASH");
        callbackGasLimit = uint32(vm.envUint("CALLBACKGASLIMIT"));
        requestConfirmations = uint16(vm.envUint("REQUESTCONFIRMATIONS"));
        numWords = uint32(vm.envUint("NUMWORDS"));
    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        redpacketdistributor = new RedPacketDistributor(
            vrfCoordinator, subscriptionId, keyHash, callbackGasLimit, requestConfirmations, numWords
        );

        console.log("RedPacketDistributor deployed to:", address(redpacketdistributor));

        vm.stopBroadcast();
    }
}
