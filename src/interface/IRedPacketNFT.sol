// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRedPacketNFT {
    ///////////////////
    // Events
    ///////////////////
    event RedPacketNFTMinted(address indexed to, uint256 indexed tokenId);

    function mint(address) external returns (uint256);
}
