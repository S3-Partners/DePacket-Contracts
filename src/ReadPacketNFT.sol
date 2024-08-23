// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ReadPacketNFT is ERC721 {
    uint256 private _nextTokenId;

    constructor() ERC721("ReadPacketNFT", "RPNFT") {}

    function mint(address to) public returns (uint256) {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);

        return tokenId;
    }

    function transfer(address from, address to, uint256 tokenId) external {
        _transfer(from, to, tokenId);
    }
}
