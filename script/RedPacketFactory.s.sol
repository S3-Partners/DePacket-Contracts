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
        nftContract = 0xc32cE2198B123D1c1F7FD3A9f54Bff9f975819Fa;
        registry = 0x7eA36391c7127A7f40E5c23212A8016d6E494546;
    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        factory = new RedPacketFactory(nftContract, registry);

        console.log("RedPacketFactory deployed to:", address(factory));

        vm.stopBroadcast();
    }
}
