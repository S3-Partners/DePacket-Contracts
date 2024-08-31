// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interface/IRedPacketFactory.sol";
import "./interface/IRedPacketNFT.sol";
import "./interface/IRedPacket.sol";
import "./interface/IERC6551Account.sol";
import "./interface/IERC6551Registry.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/// @title RedPacket
/// @notice A contract for creating and managing red packets
contract RedPacket is IRedPacket {
    ///////////////////
    // State Variables
    ///////////////////

    /// @notice The factory contract for creating red packets
    IRedPacketFactory public immutable factory;

    /// @notice The address of the register
    address public registerAddress;

    ///////////////////
    // Errors
    ///////////////////

    /// @notice Thrown when an ERC20 transfer fails
    error RedPacket__TransferFailed();

    ///////////////////
    // Constructor
    ///////////////////

    /// @notice Initializes the RedPacket contract
    /// @param _factory The address of the RedPacketFactory contract
    constructor(address _factory) {
        factory = IRedPacketFactory(_factory);
    }

    ///////////////////
    // External Functions
    ///////////////////

    /// @inheritdoc IRedPacket
    function createRedPacket(address _recipient, address _erc20, uint256 _amount)
        external
        returns (address walletContract)
    {
        walletContract = factory.createRedPacket(_recipient);
        _transferERC20IntoRedPacket(walletContract, _erc20, _amount);
        emit RedPacketCreated(walletContract, _recipient, _erc20, _amount);
    }

    ///////////////////
    // Internal Functions
    ///////////////////

    /// @notice Transfers ERC20 tokens into the red packet wallet
    /// @param _nftWallet The address of the red packet wallet
    /// @param _erc20 The address of the ERC20 token to be transferred
    /// @param _amount The amount of ERC20 tokens to be transferred
    function _transferERC20IntoRedPacket(address _nftWallet, address _erc20, uint256 _amount) internal {
        bool success = IERC20(_erc20).transferFrom(msg.sender, _nftWallet, _amount);
        if (!success) revert RedPacket__TransferFailed();
    }
}
