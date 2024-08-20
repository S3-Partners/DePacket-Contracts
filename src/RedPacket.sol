// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interface/IRedPacketFactory.sol";
import "./interface/IRedPacketNFT.sol";
import "./interface/IRedPacket.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract RedPacket is IRedPacket {

    ///////////////////
    // Errors
    ///////////////////

    error RedPacket__ERC20TransferFailed();

    ///////////////////
    // State Variables
    ///////////////////

    IRedPacketFactory public immutable redPacketFactory;

    ///////////////////
    // Constructor
    ///////////////////

    constructor(address _redPacketFactory) {
        redPacketFactory = IRedPacketFactory(_redPacketFactory);
    }

    ///////////////////
    // External Functions
    ///////////////////

    // /// @notice Opens a red packet NFT
    // /// @param _redPacketNft The address of the red packet NFT to open
    // function open(address _redPacketNft) external {
    //     IRedPacketNFT(_redPacketNft).openRedPacket();
    //     emit RedPacketOpened(_redPacketNft);
    // }

    /// @notice Creates a new red packet
    /// @param _erc20 The address of the ERC20 token to be used
    /// @param _amount The amount of tokens to be included in the red packet
    /// @param _recipient The address of the recipient of the red packet
    function create(address _erc20, uint256 _amount, address _recipient) external {
        address redPacketNft = redPacketFactory.createRedPacket( _recipient);

        bool success = IERC20(_erc20).transferFrom(msg.sender, redPacketNft, _amount);

        if (!success) {
            revert RedPacket__ERC20TransferFailed();
        }

        emit RedPacketCreated(redPacketNft);
    }
}