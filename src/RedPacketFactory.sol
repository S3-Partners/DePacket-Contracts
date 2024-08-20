// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interface/IRedPacketFactory.sol";
import "./interface/IRedPacketNFT.sol";
import "./RedPacketNFT.sol";
contract RedPacketFactory {


    function createRedPacket( address recipient) external returns (address nftContract) {


        nftContract = address(new RedPacketNFT( recipient));

        

        // create2 is used to deploy a contract with a specific address

        // bytes memory bytecode = type(RedPacketNFT).creationCode;
        // bytes32 salt = keccak256(abi.encodePacked(erc20Address, amount, recipient));

        // assembly {
        //     nftContract := create2(0, add(bytecode, 32), mload(bytecode), salt)
        // }

        
    }





}
