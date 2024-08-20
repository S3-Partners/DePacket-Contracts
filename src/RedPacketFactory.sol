// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interface/IRedPacketFactory.sol";
import "./interface/IRedPacketNFT.sol";
import "./RedPacketNFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/proxy/Clones.sol";

contract RedPacketFactory is Ownable {
    RedPacketNFT nft;
    address[] public deployedTokens;

    event deployInscriptionEvent(address indexed tokenAddress, address indexed userAddress);

    constructor(address initialOwner) Ownable(initialOwner) {}

    function setTokenAddress(address _tokenAddress) public onlyOwner {
        nft = RedPacketNFT(_tokenAddress);
    }

    function createRedPacket(address recipient) external returns (address nftContract) {
        // nftContract = address(new RedPacketNFT(recipient));
        nftContract = Clones.clone(address(nft));

        RedPacketNFT(nftContract).initialize(recipient);

        deployedTokens.push(nftContract);

        emit deployInscriptionEvent(nftContract, recipient);

        // create2 is used to deploy a contract with a specific address

        // bytes memory bytecode = type(RedPacketNFT).creationCode;
        // bytes32 salt = keccak256(abi.encodePacked(erc20Address, amount, recipient));

        // assembly {
        //     nftContract := create2(0, add(bytecode, 32), mload(bytecode), salt)
        // }
    }
}
