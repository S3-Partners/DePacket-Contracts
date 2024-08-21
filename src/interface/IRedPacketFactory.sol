// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRedPacketFactory {
    function createRedPacket(address _erc20, uint256 _amount, address _recipient,  string memory _uri) external returns (address);
}
