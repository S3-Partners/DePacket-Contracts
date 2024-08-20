// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RedPacketNFT is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    uint256 private _nextTokenId;

    struct RedPacketInfo {
        uint256 amount;
        address[] recipients;
        bool opened;
    }

    mapping(uint256 => RedPacketInfo) private _redPackets;

    constructor(
        address initialOwner
    ) ERC721("RedPacketNFT", "RPK") Ownable(initialOwner) {}

    // Open the red packet, transfers the token to the caller
    function openRedPacket(uint256 tokenId) public {
        RedPacketInfo storage packet = _redPackets[tokenId];
        require(!packet.opened, "Already opened");
        require(_isRecipient(msg.sender, packet.recipients), "Not authorized");

        packet.opened = true;
        // Transfer the amount stored in the red packet to the caller
        payable(msg.sender).transfer(packet.amount);

        safeTransferFrom(address(this), msg.sender, tokenId);
    }

    // Create a new red packet and mint the NFT
    function createRedPacket(
        address to,
        string memory uri,
        uint256 amount,
        address[] memory recipients
    ) public payable onlyOwner {
        require(msg.value == amount, "Amount must be equal to the value sent");

        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);

        _redPackets[tokenId] = RedPacketInfo({
            amount: amount,
            recipients: recipients,
            opened: false
        });
    }

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // Check if an address is in the recipients list
    function _isRecipient(
        address addr,
        address[] memory recipients
    ) internal pure returns (bool) {
        for (uint256 i = 0; i < recipients.length; i++) {
            if (recipients[i] == addr) {
                return true;
            }
        }
        return false;
    }

    // The following functions are overrides required by Solidity.

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
