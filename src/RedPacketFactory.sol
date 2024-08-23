// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ERC6551Registry.sol";
import "./ERC6551Account.sol";
import "./interface/IRedPacketNFT.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract RedPacketFactory is IERC721Receiver {
    ERC6551Registry public registry;

    address public owner;

    address public implementation;

    address public nftContract;

    uint256 chainId = block.chainid;

    error RedPacketFactory__NotOwner();

    constructor(address _nft_contract, address _registry) {
        owner = msg.sender;
        nftContract = _nft_contract;
        registry = ERC6551Registry(_registry);
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert RedPacketFactory__NotOwner();
        _;
    }

    function setImplementation(address _implementation) external onlyOwner {
        implementation = _implementation;
    }

    function getAccount(uint256 _tokenId) external view returns (address) {
        // bytes32 salt = keccak256(abi.encodePacked(address(nftContract), uint256(_tokenId)));
        bytes32 salt = bytes32(uint256(_tokenId + 100000));
        address account = registry.account(address(implementation), salt, chainId, nftContract, _tokenId);
        return account;
    }

    function createRedPacket(address recipient) external returns (address) {
        require(recipient != address(0), "Invalid recipient address");

        // mint nft token
        uint256 tokenId = IRedPacketNFT(nftContract).mint(address(this));
        require(tokenId == 0, "Minting failed");

        // bytes32 salt = keccak256(abi.encodePacked(nftContract, tokenId));
        bytes32 salt = bytes32(uint256(tokenId + 100000));

        // create account
        address redPacketAddress = registry.createAccount(implementation, salt, chainId, nftContract, tokenId);

        // transfer to recipient
        IRedPacketNFT(nftContract).transfer(address(this), recipient, tokenId);
        // Log the creation of the Red Packet
        emit RedPacketCreated(redPacketAddress, recipient, tokenId);

        return redPacketAddress;
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
    event RedPacketCreated(address indexed redPacketAddress, address indexed recipient, uint256 tokenId);
    event TokenReceived(address operator, address from, uint256 tokenId, bytes data);
}
