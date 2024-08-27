// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRedPacketNFT {
    function mint(address, string memory uri) external returns (uint256);
    function transfer(address from, address to, uint256 tokenId) external;
}
