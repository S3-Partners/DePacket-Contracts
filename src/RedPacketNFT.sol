// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./interface/IRedPacketNFT.sol";

contract RedPacketNFT is ERC721 {
    event RedPacketNFTMinted(address indexed to, uint256 indexed tokenId);
    ///////////////////
    // Errors
    ///////////////////
    error RedPacketNFT__InvalidAddress();

    ///////////////////
    // State Variables
    ///////////////////
    uint256 private _nextTokenId;

    string private constant BASE_URI =
        "https://coral-imperial-mule-141.mypinata.cloud/ipfs/QmR5LCfHvT4NaCPewACgDTMRCRqfjBk8d1Jt9xdKWSdzGr";

    ///////////////////
    // Constructor
    ///////////////////
    constructor() ERC721("RedPacketNFTMOON", "RPNFTMOON") {}

    ///////////////////
    // Public Functions
    ///////////////////
    /// @notice Mints a new RedPacketNFT to the specified address
    /// @param to The address to mint the NFT to
    /// @return tokenId The ID of the newly minted NFT
    function mint(address to) public returns (uint256 tokenId) {
        if (to == address(0)) revert RedPacketNFT__InvalidAddress();

        tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        emit RedPacketNFTMinted(to, tokenId);
    }

    function tokenURI(uint256) public pure override returns (string memory) {
        return BASE_URI;
    }
}
