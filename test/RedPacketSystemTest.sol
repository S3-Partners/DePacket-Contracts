// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../src/RedPacket.sol";
import "forge-std/Test.sol";
import "../src/RedPacketFactory.sol";
import "../src/ReadPacketNFT.sol";
import "../src/ERC6551Registry.sol";
import "../src/ERC6551Account.sol";
import "../src/interface/IERC6551Account.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract RedPacketTest is Test {
    RedPacket public redPacket;
    RedPacketFactory public factory;
    ReadPacketNFT public nft;
    ERC6551Registry public registry;
    ERC6551Account public implementation;
    MockERC20 public mockERC20;
    ERC1967Proxy proxy;
    address public owner;
    address public recipient;
    string public uri = "QmQv8bBST1D89j6q14L7wUzBeYgsovJ8ywvsCUhghLH5Qd";

    event ERC6551AccountCreated(
        address account,
        address indexed implementation,
        bytes32 salt,
        uint256 chainId,
        address indexed tokenContract,
        uint256 indexed tokenId
    );

    function setUp() public {
        owner = address(this);
        recipient = address(0x123);

        // Deploy contracts
        nft = new ReadPacketNFT();

        registry = new ERC6551Registry();
        implementation = new ERC6551Account();
        factory = new RedPacketFactory(address(nft), address(registry));
        factory.setImplementation(address(implementation));

        // redPacket = new RedPacket();
        // redPacket.initialize(address(owner), address(factory));
        // 部署实现
        RedPacket implementation_red_packet = new RedPacket();
        // Deploy the proxy and initialize the contract through the proxy
        proxy = new ERC1967Proxy(
            address(implementation_red_packet),
            abi.encodeCall(implementation_red_packet.initialize, (address(owner), address(factory)))
        );
        // 用代理关联 RedPacket 接口
        redPacket = RedPacket(address(proxy));

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
        address wallet = redPacket.createRedPacket(recipient, address(mockERC20), amount, uri);

        //check wallet address balance
        uint256 balance = IERC20(address(mockERC20)).balanceOf(wallet);

        //check wallet from registry
        bytes32 salt = bytes32(uint256(0 + 100000));

        uint256 chainId = block.chainid;
        address walletaddress = registry.account(address(implementation), salt, chainId, address(nft), 0);

        address _redPacketNft = factory.getAccount(uint256(0));

        uint256 balance2 = IERC20(address(mockERC20)).balanceOf(_redPacketNft);
        assertEq(walletaddress, _redPacketNft);
        assertEq(wallet, _redPacketNft);
        // check recipient balance
        assertEq(balance, balance2);
    }

    function testOpenRedPacket() public {
        testCreateRedPacket();

        address account = factory.getAccount(0);

        IERC6551Account accountInstance = IERC6551Account(payable(account));
        IERC6551Executable executableAccountInstance = IERC6551Executable(account);

        // Get the balance of ERC20 tokens in the account
        uint256 erc20Balance = IERC20(mockERC20).balanceOf(account);
        assertEq(erc20Balance, 1000 * 10 ** 18);
        require(erc20Balance > 0, "No ERC20 tokens to withdraw");

        // Prepare the call data for the ERC20 transfer
        bytes memory data = abi.encodeWithSelector(IERC20.transfer.selector, recipient, erc20Balance);

        // Call the execute function on the ERC6551Account to transfer ERC20 tokens
        vm.prank(recipient);
        executableAccountInstance.execute(address(mockERC20), 0, data, 0);
        assertEq(accountInstance.state(), 1);
        uint256 recipientErc20Balance = IERC20(mockERC20).balanceOf(recipient);
        assertEq(recipientErc20Balance, 1000 * 10 ** 18);
    }

    function testDeploy() public {
        uint256 chainId = 100;
        address tokenAddress = address(200);
        uint256 tokenId = 300;
        bytes32 salt = bytes32(uint256(400));

        address deployedAccount = registry.createAccount(address(implementation), salt, chainId, tokenAddress, tokenId);

        address registryComputedAddress =
            registry.account(address(implementation), salt, chainId, tokenAddress, tokenId);
        console.log(deployedAccount, "deployedAccount");
        console.log(registryComputedAddress);
        assertEq(deployedAccount, registryComputedAddress);
    }

    function testDeploy2() public {
        uint256 chainId = 100;
        address tokenAddress = address(200);
        uint256 tokenId = 300;
        bytes32 salt = bytes32(uint256(400));

        address account = registry.account(address(implementation), salt, chainId, tokenAddress, tokenId);

        vm.expectEmit(true, true, true, true);
        emit ERC6551AccountCreated(account, address(implementation), salt, chainId, tokenAddress, tokenId);

        address deployedAccount = registry.createAccount(address(implementation), salt, chainId, tokenAddress, tokenId);
        assertEq(deployedAccount, account);

        deployedAccount = registry.createAccount(address(implementation), salt, chainId, tokenAddress, tokenId);
        assertEq(deployedAccount, account);
    }

    function testDeployFuzz(
        address _implementation,
        uint256 chainId,
        address tokenAddress,
        uint256 tokenId,
        bytes32 salt
    ) public {
        vm.assume(salt <= bytes32(uint256(type(uint160).max)));
        address account = registry.account(_implementation, salt, chainId, tokenAddress, tokenId);

        address deployedAccount = registry.createAccount(_implementation, salt, chainId, tokenAddress, tokenId);

        assertEq(deployedAccount, account);
    }

    function testCall() public {
        nft.mint(vm.addr(1), uri);

        address account = registry.createAccount(address(implementation), 0, block.chainid, address(nft), 0);
        assertTrue(account != address(0));

        IERC6551Account accountInstance = IERC6551Account(payable(account));
        IERC6551Executable executableAccountInstance = IERC6551Executable(account);

        assertEq(accountInstance.isValidSigner(vm.addr(1), ""), IERC6551Account.isValidSigner.selector);

        vm.deal(account, 1 ether);

        vm.prank(vm.addr(1));
        executableAccountInstance.execute(payable(vm.addr(2)), 0.5 ether, "", 0);

        assertEq(account.balance, 0.5 ether);
        assertEq(vm.addr(2).balance, 0.5 ether);
        assertEq(accountInstance.state(), 1);
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
