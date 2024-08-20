// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {RedPacket} from "../src/RedPacket.sol";
import {RedPacketNFT} from "../src/RedPacketNFT.sol";
import {RedPacketFactory} from "../src/RedPacketFactory.sol";

contract RedPacketToken is ERC20, Ownable {
    constructor(address initialOwner) ERC20("RedPacketToken", "RTK") Ownable(initialOwner) {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}

contract RedPacketTest is Test {
    RedPacket public redpacket;
    RedPacketToken public token;
    RedPacketNFT public nft;
    RedPacketFactory public factory;

    ERC1967Proxy proxy;

    Account owner = makeAccount("owner");
    Account alice = makeAccount("alice");
    Account bob = makeAccount("bob");

    uint256 internal amount = 1 * 10 ** 18;

    function setUp() public {
        token = new RedPacketToken(owner.addr);
        factory = new RedPacketFactory(owner.addr);
        redpacket = new RedPacket(address(factory));

        RedPacketNFT implementation = new RedPacketNFT();
        vm.prank(owner.addr);
        proxy = new ERC1967Proxy(address(implementation), abi.encodeCall(implementation.initialize, (owner.addr)));

        // 用代理关联 TokenFactoryV2 接口
        nft = RedPacketNFT(address(proxy));

        vm.startPrank(owner.addr);

        token.mint(owner.addr, amount);
        factory.setTokenAddress(address(nft));
        token.approve(address(nft), amount);
        vm.stopPrank();
    }

    function testCreateSuccess() public {
        vm.startPrank(owner.addr);
        redpacket.create(address(token), amount, address(alice.addr));
        vm.stopPrank();
    }
}
