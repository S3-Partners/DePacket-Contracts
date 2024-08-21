// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Test, console} from "forge-std/Test.sol";

contract RedPacketNFT is
    Initializable,
    ERC721Upgradeable,
    ERC721URIStorageUpgradeable,
    ERC721BurnableUpgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    uint256 private _nextTokenId;
    uint256 public constant feeBP = 30; // 30/10000 = 0.3%
    address public feeTo;
    address public constant ETH_FLAG = address(0);

    struct RedPacketInfo {
        uint256 amount;
        address recipient;
        bool opened;
        address payToken;
        address sendPacket;
    }

    mapping(uint256 => RedPacketInfo) private _redPackets;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) public initializer {
        __ERC721_init("RedPacketNFT", "RPK");
        __ERC721URIStorage_init();
        __ERC721Burnable_init();
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        console.log("create initialize");
    }

    function openRedPacket(uint256 tokenId, address recipient) public payable {
        _openRedPacket(tokenId, recipient, feeTo);
    }

    // Open the red packet, transfers the token to the caller
    function openRedPacket(uint256 tokenId, address recipient, bytes calldata signature) external payable {
        _openRedPacket(tokenId, recipient, address(0));
    }

    function _openRedPacket(uint256 tokenId, address recipient, address feeReceiver) private {
        RedPacketInfo storage packet = _redPackets[tokenId];
        require(!packet.opened, "Already opened");
        console.log("address(this): ", address(this));

        require(recipient == packet.recipient, "Not authorized");

        packet.opened = true;
        safeTransferFrom(packet.sendPacket, recipient, tokenId);

        // trasnfer token
        // fee 0.3% or 0
        uint256 fee = feeReceiver == address(0) ? 0 : (packet.amount * feeBP) / 10000;
        // safe check
        if (packet.payToken == ETH_FLAG) {
            require(msg.value == packet.amount, "RPK: wrong eth value");
        } else {
            require(msg.value == 0, "RPK: ETH value should be zero");
        }
        _transferOut(packet.payToken, recipient, packet.amount - fee);
        if (fee > 0) _transferOut(packet.payToken, feeReceiver, fee);

        emit OpenRedPacketEvent(tokenId, recipient, fee);
    }

    function _transferOut(address token, address to, uint256 amount) private {
        if (token == ETH_FLAG) {
            // eth
            // Transfer the amount stored in the red packet to the caller
            // payable(msg.sender).transfer(amount);
            (bool success,) = to.call{value: amount}("");
            require(success, "RPK: transfer fee failed");
        } else {
            SafeERC20.safeTransferFrom(IERC20(token), address(this), to, amount);
        }
    }

    // Create a new red packet and mint the NFT
    function createRedPacket(address to, string memory uri, address _erc20, uint256 _amount, address _recipient)
        public
        payable
    {
        // require(msg.value == _amount, "Amount must be equal to the value sent");

        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        console.log("Created new red packet with token ID: %s", tokenId);
        _setTokenURI(tokenId, uri);

        _redPackets[tokenId] =
            RedPacketInfo({amount: _amount, recipient: _recipient, opened: false, payToken: _erc20, sendPacket: to});

        emit CreatedRedPacket(tokenId, to, _amount, _recipient);
    }

    function setFeeTo(address to) external onlyOwner {
        require(feeTo != to, "MKT:repeat set");
        feeTo = to;

        emit SetFeeTo(to);
    }

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    // The following functions are overrides required by Solidity.

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    event SetFeeTo(address to);
    event CreatedRedPacket(uint256 tokenId, address to, uint256 amount, address recipient);
    event OpenRedPacketEvent(uint256 tokenId, address recipient, uint256 fee);
}
