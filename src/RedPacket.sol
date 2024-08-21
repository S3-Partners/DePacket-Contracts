// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interface/IRedPacketFactory.sol";
import "./interface/IRedPacketNFT.sol";
import "./interface/IRedPacket.sol";
import "./interface/IERC6551Account.sol";
import "./interface/IERC6551Registry.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";



contract RedPacket is IRedPacket {
    IRedPacketFactory public factory;

    address public registerAddress;

    // event RedPacketCreated(address walletContract, address recipient, address _erc20, uint amount);
    event RedPacketOpened(address redPacketNft, address recipient, uint256 amount);

    constructor(address _factory) {
        factory = IRedPacketFactory(_factory);
    }

    error RedPacket_Transfer_Failed();

    function createRedPacket(address recipient, address _erc20, uint256 amount)
        external
        returns (address walletContract)
    {
        walletContract = factory.createRedPacket(recipient);
        

        _transferUsdtIntoRedPacket(walletContract, _erc20, amount);

        emit RedPacketCreated(walletContract, recipient, _erc20, amount);
    }

    


    function _transferUsdtIntoRedPacket(address _nft_wallet, address _erc20, uint256 amount) internal {
        bool result = IERC20(_erc20).transferFrom(msg.sender, _nft_wallet, amount);

        if (!result) revert RedPacket_Transfer_Failed();
    }
}
