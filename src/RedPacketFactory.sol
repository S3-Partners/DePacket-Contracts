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
    mapping(address => address) public tokenDeployUser;

    event RedPacketDeployed(address indexed tokenAddress, address indexed userAddress, address indexed recipient);

    constructor(address initialOwner) Ownable(initialOwner) {}

    function setTokenAddress(address _tokenAddress) public onlyOwner {
        nft = RedPacketNFT(_tokenAddress);
    }

    function createRedPacket(address to, address _erc20, uint256 _amount, address _recipient, string memory _uri)
        external
        returns (address nftContract)
    {
        require(to != address(0), "Invalid 'to' address");
        require(_recipient != address(0), "Invalid recipient address");

        nftContract = Clones.clone(address(nft));

        RedPacketNFT(nftContract).initialize(_recipient);
        RedPacketNFT(nftContract).createRedPacket(to, _uri, _erc20, _amount, _recipient);
        deployedTokens.push(nftContract);
        tokenDeployUser[nftContract] = to;

        emit RedPacketDeployed(nftContract, to, _recipient);
    }

    function size() public view returns (uint256) {
        return deployedTokens.length;
    }
}
