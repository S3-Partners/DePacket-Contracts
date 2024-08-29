// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {RedPacketNFT} from "../src/RedPacketNFT.sol";

contract ReadPacketNFTScript is Script {
    RedPacketNFT public nft;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        nft = new RedPacketNFT();

        console.log("ReadPacketNFT deployed to:", address(nft));

        vm.stopBroadcast();
    }
}
