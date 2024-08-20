// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IRedPacketFactory {

    function createRedPacket(address erc20Address,uint256 amount,address recipient) external returns (address);

}