// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

///////////////////
// IRedPacket Interface
///////////////////

interface IRedPacket {
    ///////////////////
    // Events
    ///////////////////

    event RedPacketCreated(address indexed walletContract, address indexed recipient, address _erc20, uint256 amount);

    ///////////////////
    // Functions
    ///////////////////
    function createRedPacket(address _recipient, address _erc20, uint256 _amount, string memory _uri)
        external
        returns (address walletContract);
}
