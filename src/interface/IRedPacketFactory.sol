// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IRedPacketFactory Interface
/// @notice Interface for the RedPacketFactory contract
interface IRedPacketFactory {
    ///////////////////
    // Events
    ///////////////////

    /// @notice Emitted when a new red packet is created
    /// @param redPacketAddress The address of the newly created red packet wallet
    /// @param recipient The address of the recipient of the red packet
    /// @param tokenId The ID of the NFT associated with this red packet
    event RedPacketCreated(address indexed redPacketAddress, address indexed recipient, uint256 tokenId);

    ///////////////////
    // External Functions
    ///////////////////

    /// @notice Sets the implementation address for red packet wallets
    /// @param _implementation The new implementation address
    function setImplementation(address _implementation) external;

    /// @notice Sets the NFT contract address
    /// @param _nftContract The new NFT contract address
    function setNftContract(address _nftContract) external;

    /// @notice Creates a new red packet
    /// @param recipient The address of the recipient of the red packet
    /// @return The address of the newly created red packet wallet
    function createRedPacket(address recipient) external returns (address);

    ///////////////////
    // External View Functions
    ///////////////////

    /// @notice Gets the account address for a given token ID
    /// @param _tokenId The ID of the token
    /// @return The address of the account associated with the token ID
    function getAccount(uint256 _tokenId) external view returns (address);
}