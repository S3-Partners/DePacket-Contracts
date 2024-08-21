// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ERC6551Registry.sol";

import "./ERC6551Account.sol";
import "./interface/IRedPacketNFT.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract RedPacketFactory {
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

    function getAccount( uint256 _tokenId) external view returns (address) {
        bytes32 salt = keccak256(abi.encodePacked(address(nftContract), uint(_tokenId)));
        
        address account = registry.account(address(implementation), salt, chainId, nftContract, _tokenId);
        return account;
    }

    function createRedPacket(address recipient) external returns (address) {
        // mint nft token
        uint256 tokenId = IRedPacketNFT(nftContract).mint(address(this));

        bytes32 salt = keccak256(abi.encodePacked(nftContract, tokenId));
        
        // create account
        address redPacketAddress = registry.createAccount(implementation, salt, chainId, nftContract, tokenId);

        // transfer to recipient
        IRedPacketNFT(nftContract).transfer(address(this), recipient, tokenId);

        return redPacketAddress;
    }
}
