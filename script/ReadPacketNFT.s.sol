// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ReadPacketNFT} from "../src/ReadPacketNFT.sol";

contract ReadPacketNFTScript is Script {
    ReadPacketNFT public nft;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        nft = new ReadPacketNFT();

        console.log("ReadPacketNFT deployed to:", address(nft));

        vm.stopBroadcast();
    }
}
