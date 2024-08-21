// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRedPacketFactory {
    function createRedPacket(address recipient) external returns (address);
    function getAccount(address _tokenContract, uint256 _tokenId) external view returns (address);
    
}
