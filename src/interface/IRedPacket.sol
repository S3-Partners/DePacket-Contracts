// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IRedPacket Interface
/// @notice Interface for the RedPacket contract
interface IRedPacket {
    ///////////////////
    // Events
    ///////////////////

    /// @notice Emitted when a new red packet is created
    /// @param walletContract The address of the newly created red packet wallet
    /// @param recipient The address of the recipient of the red packet
    /// @param erc20 The address of the ERC20 token used for the red packet
    /// @param amount The amount of ERC20 tokens in the red packet
    event RedPacketCreated(address indexed walletContract, address indexed recipient, address erc20, uint256 amount);

    ///////////////////
    // External Functions
    ///////////////////

    /// @notice Creates a new red packet
    /// @param _recipient The address of the recipient of the red packet
    /// @param _erc20 The address of the ERC20 token to be used
    /// @param _amount The amount of ERC20 tokens to be transferred
    /// @return walletContract The address of the newly created red packet wallet
    function createRedPacket(address _recipient, address _erc20, uint256 _amount)
        external
        returns (address walletContract);
}
