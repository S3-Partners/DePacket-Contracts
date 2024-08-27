// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {RedPacketFactory} from "../src/RedPacketFactory.sol";
import {ReadPacketNFT} from "../src/ReadPacketNFT.sol";
import {ERC6551Registry} from "../src/ERC6551Registry.sol";

contract RedPacketFactoryScript is Script {
    RedPacketFactory public factory;
    address public nftContract;
    address public registry;

    function setUp() public {
        nftContract = 0xD841a44e21c5F0944d1b022C6172865288F3C077;
        registry = 0x724401E256D94eA9c8567cCbE23eC977B20AE37b;
    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        factory = new RedPacketFactory(nftContract, registry);

        console.log("RedPacketFactory deployed to:", address(factory));

        vm.stopBroadcast();
    }
}
