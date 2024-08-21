// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRedPacketNFT {
    function mint(address) external returns (uint);
    function transfer(address from, address to, uint256 tokenId) external;
}
