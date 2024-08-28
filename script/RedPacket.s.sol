// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {RedPacket} from "../src/RedPacket.sol";

contract RedPacketScript is Script {
    address public factory;

    function setUp() public {
        // Read the factory address from environment variables
        factory = vm.envAddress("FACTORY_ADDRESS");
    }

    function run() public {
        // Read the deployer's private key from environment variables
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        console.log("Deploying contracts with the account:", deployerAddress);

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the RedPacket contract
        RedPacket redpacket = new RedPacket(factory);
        // RedPacket redpacket = new RedPacket();
        console.log("RedPacket deployed to:", address(redpacket));

        // Encode the initializer function call
        // bytes memory data = abi.encodeCall(redpacket.initialize, (deployerAddress, factory));

        // Deploy the proxy contract with the implementation address and initializer data
        // ERC1967Proxy proxy = new ERC1967Proxy(address(redpacket), data);

        // Stop broadcasting transactions
        vm.stopBroadcast();

        // Log the proxy contract address
        // console.log("RedPacket UUPS Proxy Address:", address(proxy));
    }
}
