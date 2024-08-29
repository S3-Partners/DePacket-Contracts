// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ERC6551Registry.sol";
import "./interface/IRedPacketNFT.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/IRedPacketFactory.sol";

/// @title RedPacketFactory
/// @notice A factory contract for creating and managing red packet wallets
contract RedPacketFactory is Ownable, IRedPacketFactory {
    ///////////////////
    // State Variables
    ///////////////////

    /// @notice The ERC6551Registry contract used for creating token bound accounts
    ERC6551Registry public registry;

    /// @notice The implementation address for red packet wallets
    address public implementation;

    /// @notice The address of the NFT contract associated with red packets
    address public nftContract;

    /// @notice The chain ID of the network this contract is deployed on
    uint256 private immutable CHAIN_ID;

    ///////////////////
    // Errors
    ///////////////////

    /// @notice Thrown when an invalid recipient address is provided
    error RedPacketFactory__InvalidRecipient();

    ///////////////////
    // Constructor
    ///////////////////

    /// @notice Initializes the RedPacketFactory contract
    /// @param _nftContract The address of the NFT contract
    /// @param _registry The address of the ERC6551Registry contract
    /// @param _implementation The address of the red packet wallet implementation
    constructor(address _nftContract, address _registry, address _implementation) Ownable(msg.sender) {
        implementation = _implementation;
        nftContract = _nftContract;
        registry = ERC6551Registry(_registry);
        CHAIN_ID = block.chainid;
    }

    ///////////////////
    // External Functions
    ///////////////////

    /// @inheritdoc IRedPacketFactory
    function setImplementation(address _implementation) external onlyOwner {
        implementation = _implementation;
    }

    /// @inheritdoc IRedPacketFactory
    function setNftContract(address _nftContract) external onlyOwner {
        require(_nftContract != address(0), "Invalid address: zero address");
        nftContract = _nftContract;
    }

    /// @inheritdoc IRedPacketFactory
    function createRedPacket(address recipient) external returns (address) {
        if (recipient == address(0)) revert RedPacketFactory__InvalidRecipient();

        uint256 tokenId = IRedPacketNFT(nftContract).mint(recipient);
        bytes32 salt = keccak256(abi.encodePacked(tokenId, nftContract));
        address redPacketWalletAddress = registry.createAccount(implementation, salt, CHAIN_ID, nftContract, tokenId);

        emit RedPacketCreated(redPacketWalletAddress, recipient, tokenId);

        return redPacketWalletAddress;
    }

    ///////////////////
    // External View Functions
    ///////////////////

    /// @inheritdoc IRedPacketFactory
    function getAccount(uint256 _tokenId) external view returns (address) {
        bytes32 salt = keccak256(abi.encodePacked(_tokenId, nftContract));
        return registry.account(implementation, salt, CHAIN_ID, nftContract, _tokenId);
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        returns (bytes4)
    {
        // 记录接收到的代币信息
        emit TokenReceived(operator, from, tokenId, data);
        return this.onERC721Received.selector;
    }

    // Event declaration
    event TokenReceived(address operator, address from, uint256 tokenId, bytes data);
    event NFTContractUpdated(address indexed oldAddress, address indexed newAddress);
}
