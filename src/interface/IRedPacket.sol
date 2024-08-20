// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

///////////////////
// IRedPacket Interface
///////////////////

interface IRedPacket {
    ///////////////////
    // Events
    ///////////////////

    /// @notice Emitted when a red packet is opened
    /// @param redPacketNft The address of the opened red packet NFT
    event RedPacketOpened(address indexed redPacketNft);

    /// @notice Emitted when a new red packet is created
    /// @param redPacketNft The address of the newly created red packet NFT
    event RedPacketCreated(address indexed redPacketNft);

    ///////////////////
    // External Functions
    ///////////////////

    // /// @notice Opens a red packet NFT
    // /// @param _redPacketNft The address of the red packet NFT to open
    // function open(address _redPacketNft) external;

    /// @notice Creates a new red packet
    /// @param _erc20 The address of the ERC20 token to be used
    /// @param _amount The amount of tokens to be included in the red packet
    /// @param _recipient The address of the recipient of the red packet
    function create(address _erc20, uint256 _amount, address _recipient) external;
}
