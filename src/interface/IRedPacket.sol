// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

///////////////////
// IRedPacket Interface
///////////////////

interface IRedPacket {
    ///////////////////
    // Events
    ///////////////////

    event RedPacketCreated(address indexed walletContract, address indexed recipient, address _erc20, uint256 amount);

    /// @notice Emitted when a red packet is opened
    /// @param redPacketNft The address of the opened red packet NFT
    ///////////////////
    // External Functions
    ///////////////////

    // /// @notice Opens a red packet NFT
    // /// @param _redPacketNft The address of the red packet NFT to open
    // function open(address _redPacketNft) external;
}
