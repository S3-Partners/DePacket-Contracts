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
    address public account;

    function setUp() public {
        nftContract = vm.envAddress("NFT_CONTRACT_ADDRESS");
        registry = vm.envAddress("REGISTRY_ADDRESS");
        account = vm.envAddress("ERC6551Account_ADDRESS");
    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        factory = new RedPacketFactory(nftContract, registry);

        console.log("RedPacketFactory deployed to:", address(factory));

        vm.stopBroadcast();
    }
}
