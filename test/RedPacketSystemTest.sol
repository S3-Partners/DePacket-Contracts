// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../src/RedPacket.sol";
import "forge-std/Test.sol";
import "../src/RedPacketFactory.sol";
import "../src/ReadPacketNFT.sol";
import "../src/ERC6551Registry.sol";
// import "../src/ERC6551Account.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract RedPacketTest is Test {
    RedPacket public redPacket;
    RedPacketFactory public factory;
    ReadPacketNFT public nft;
    ERC6551Registry public registry;
    ERC6551Account public implementation;
    MockERC20 public mockERC20;
    address public owner;
    address public recipient;

    function setUp() public {
        owner = address(this);
        recipient = address(0x123);

        // Deploy contracts
        nft = new ReadPacketNFT();
        console.log("NFT address: %s", address(nft));
        registry = new ERC6551Registry();
        implementation = new ERC6551Account();
        factory = new RedPacketFactory(address(nft), address(registry));
        factory.setImplementation(address(implementation));

        redPacket = new RedPacket(address(factory));

        // Deploy mock ERC20 token
        mockERC20 = new MockERC20();
    }

    function testCreateRedPacket() public {
        uint256 amount = 1000 ether;

        assertEq(nft.balanceOf(recipient), 0);

        // Mint tokens to this contract
        mockERC20.mint(address(this), amount);

        // Approve RedPacket contract to spend tokens
        mockERC20.approve(address(redPacket), amount);

        // Create red packet
        address wallet =redPacket.createRedPacket(recipient, address(mockERC20), amount);

        //check wallet address balance


        uint256 balance = IERC20(address(mockERC20)).balanceOf(wallet);

        //check wallet from registry
        bytes32 salt = keccak256(abi.encodePacked(address(nft), uint(0)));

        uint256 chainId = block.chainid;
        address walletaddress = registry.account(address(implementation), salt, chainId, address(nft), 0);

        console.log("origin---1-1-1-1-1-1--1-", walletaddress);
        console.log("=====================", wallet);
        console.log("Balance: %s", balance);
        address _redPacketNft = factory.getAccount(uint256(0));

        uint256 balance2 = IERC20(address(mockERC20)).balanceOf(_redPacketNft);
        

        console.log("xxxxxxxxxxddwdwddwxxxxxxxxxxx", _redPacketNft);
        console.log("=============Balance: %s", balance2);

        // check recepient balance
        
    }

    function testOpenRedPacket() public {

        address _redPacketNft = factory.getAccount( 0);

        console.log("RedPacketNFT address: %s", _redPacketNft);

        // Get the token details
        // (uint256 chainId, address tokenContract, uint256 tokenId) = IERC6551Account(_redPacketNft).token();

        // // Ensure the caller is the owner of the NFT
        // require(IERC721(tokenContract).ownerOf(tokenId) == msg.sender, "Not the owner of the NFT");

        // // Get the balance of ERC20 tokens in the account
        // uint256 erc20Balance = IERC20(_erc20).balanceOf(_redPacketNft);

        // require(erc20Balance > 0, "No ERC20 tokens to withdraw");

        // // Prepare the call data for the ERC20 transfer
        // bytes memory data = abi.encodeWithSelector(IERC20.transfer.selector, msg.sender, erc20Balance);

        // // Call the execute function on the ERC6551Account to transfer ERC20 tokens
        // IERC6551Executable(_redPacketNft).execute(_erc20, 0, data, 0);

        // // Emit an event
        // emit RedPacketOpened(_redPacketNft, msg.sender, erc20Balance);
    }
}

// Mock ERC20 token for testing
contract MockERC20 is IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;

    function mint(address account, uint256 amount) public {
        _totalSupply += amount;
        _balances[account] += amount;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, msg.sender, currentAllowance - amount);
        }
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
    }
}
