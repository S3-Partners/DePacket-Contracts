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
    uint256 internal tokenId = 0;

    function setUp() public {
        token = new RedPacketToken(owner.addr);
        factory = new RedPacketFactory(owner.addr);
        redpacket = new RedPacket(address(factory));

        vm.prank(owner.addr);
        nft = new RedPacketNFT();
        vm.startPrank(owner.addr);

        token.mint(owner.addr, amount);
        factory.setTokenAddress(address(nft));
        token.approve(address(redpacket), amount);
        vm.stopPrank();
    }

    function testCreateSuccess() public {
        vm.startPrank(owner.addr);
        assertEq(token.balanceOf(owner.addr), amount);
        redpacket.create(address(token), amount, address(alice.addr));
        assertEq(factory.size(), 1);
        address redPacketNft = factory.deployedTokens(0);
        assertEq(token.balanceOf(redPacketNft), amount);
        vm.stopPrank();
    }

    function testOpenSuccess() public {
        vm.startPrank(owner.addr);
        redpacket.create(address(token), amount, address(alice.addr));

        assertEq(factory.size(), 1);
        address redPacketNft = factory.deployedTokens(0);

        RedPacketNFT(redPacketNft).setApprovalForAll(address(redpacket), true);

        token.approve(address(redpacket), amount);
        token.approve(address(redPacketNft), amount);
        token.approve(alice.addr, amount);
        vm.stopPrank();

        vm.startPrank(alice.addr);
        assertEq(RedPacketNFT(redPacketNft).ownerOf(0), owner.addr);
        assertEq(token.balanceOf(redPacketNft), amount);
        assertEq(token.balanceOf(owner.addr), 0);
        assertEq(token.balanceOf(alice.addr), 0);
        redpacket.open(redPacketNft, 0);
        // 调用代理合约中的 openRedPacket 方法
        // 使用明确的函数选择器进行调用，避免重载问题
        // (bool success,) =
        //     address(proxy).call(abi.encodeWithSelector(bytes4(keccak256("openRedPacket(uint256)")), tokenId));
        // assertTrue(success, "Open red packet failed");
        // assertEq(token.balanceOf(redPacketNft), 0);
        // assertEq(token.balanceOf(alice.addr), amount);
        vm.stopPrank();
    }
}
