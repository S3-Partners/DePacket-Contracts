// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRedPacketFactory {
    function createRedPacket(address recipient, string memory uri) external returns (address);

    function getAccount(address _tokenContract, uint256 _tokenId) external view returns (address);
}
