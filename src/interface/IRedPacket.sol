// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IRedPacket Interface
/// @notice Interface for the RedPacket contract
interface IRedPacket {
    ///////////////////
    // Events
    ///////////////////

 

    event RedPacketCreated(address indexed walletContract, address indexed recipient, uint256 cover, uint256 amount);
    function createRedPacket(address recipient,uint256 cover) external returns (address);
    ///////////////////
    // External Functions
    ///////////////////

  
}
