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
        bytes32 salt = generateHash(_tokenId, nftContract);
        address account = registry.account(address(implementation), salt, chainId, nftContract, _tokenId);
        return account;
    }

    function createRedPacket(address recipient, string memory uri) external returns (address) {
        require(recipient != address(0), "Invalid recipient address");

        // mint nft token
        uint256 tokenId = IRedPacketNFT(nftContract).mint(recipient, uri);

        bytes32 salt = generateHash(tokenId, nftContract);
        // create account
        address redPacketAddress = registry.createAccount(implementation, salt, chainId, nftContract, tokenId);

        // Log the creation of the Red Packet
        emit RedPacketCreated(redPacketAddress, recipient, tokenId);

        return redPacketAddress;
    }

    function generateHash(uint256 tokenId, address contractAddress) public pure returns (bytes32) {
        bytes32 fullHash = keccak256(abi.encodePacked(tokenId, contractAddress));

        bytes20 truncatedHash = bytes20(fullHash);

        bytes32 finalHash = bytes32(uint256(uint160(truncatedHash)));

        bytes32 maxBytes32 = bytes32(uint256(type(uint160).max));

        require(finalHash <= maxBytes32, "Generated hash is greater than or equal to maxBytes32");

        return finalHash;
    }

    function setNFTContract(address contractAddress) public onlyOwner {
        require(contractAddress != address(0), "Invalid address: zero address");
        address oldAddress = nftContract;
        nftContract = contractAddress;
        emit NFTContractUpdated(oldAddress, contractAddress);
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
    event NFTContractUpdated(address indexed oldAddress, address indexed newAddress);
}
