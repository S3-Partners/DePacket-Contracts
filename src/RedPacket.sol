// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interface/IRedPacketFactory.sol";
import "./interface/IRedPacketNFT.sol";
import "./interface/IRedPacket.sol";
import "./interface/IERC6551Account.sol";
import "./interface/IERC6551Registry.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract RedPacket is IRedPacket {
    IRedPacketFactory public factory;

    error RedPacket_Transfer_Failed();

    ///////////////////
    // Constructor
    ///////////////////

    constructor(address _redPacketFactory) {
        factory = IRedPacketFactory(_redPacketFactory);
    }

    function createRedPacket(address _recipient, address _erc20, uint256 _amount, string memory _uri)
        external
        returns (address walletContract)
    {
        walletContract = factory.createRedPacket(_recipient, _uri);
        _transferUsdtIntoRedPacket(walletContract, _erc20, _amount);
        emit RedPacketCreated(walletContract, _recipient, _erc20, _amount);
    }

    function _transferUsdtIntoRedPacket(address _nft_wallet, address _erc20, uint256 _amount) internal {
        bool result = IERC20(_erc20).transferFrom(msg.sender, _nft_wallet, _amount);

        if (!result) revert RedPacket_Transfer_Failed();
    }
}
