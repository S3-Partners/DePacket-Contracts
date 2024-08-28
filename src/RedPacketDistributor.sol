// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {IVRFCoordinatorV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract RedPacketDistributor is VRFConsumerBaseV2Plus {
    using Address for address payable;

    uint256 public redPacketCount;
    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 s_subscriptionId;
    uint32 callbackGasLimit = 2_500_000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;

    struct RedPacketInfo {
        uint256 totalAmount;
        uint256 remainingAmount;
        uint256 remainingPackets;
        address recipient;
        address erc20;
    }

    mapping(uint256 => RedPacketInfo) public redPackets;
    mapping(address => mapping(uint256 => bool)) public hasClaimed; // 每个地址是否已经领取过特定的红包

    mapping(uint256 => address) public requestToSender;
    mapping(uint256 => uint256) public requestToRedPacketId;

    event RedPacketCreated(uint256 indexed id, uint256 totalAmount, uint256 numPackets);
    event RedPacketClaimed(uint256 indexed id, address indexed claimer, uint256 amount);
    event RandomnessRequested(uint256 requestId, address roller);

    constructor(address _vrfCoordinator, bytes32 _keyHash, uint256 subscriptionId)
        VRFConsumerBaseV2Plus(_vrfCoordinator)
    {
        keyHash = _keyHash;
        s_subscriptionId = subscriptionId;
    }

    function createRedPacket(uint256 numPackets, address _recipient, address _erc20, uint256 _amount)
        external
        onlyOwner
    {
        require(_amount > 0, "RedPacket: Amount must be greater than 0");
        require(numPackets > 0, "RedPacket: Number of packets must be greater than 0");
        require(_recipient != address(0), "RedPacket: Recipient address cannot be zero");
        require(_erc20 != address(0), "RedPacket: ERC20 address cannot be zero");

        // 增加计数器
        redPacketCount++;
        uint256 id = redPacketCount;

        // 将 ERC20 代币从合约所有者转移到合约
        IERC20 token = IERC20(_erc20);
        require(token.transferFrom(msg.sender, address(this), _amount), "RedPacket: Transfer failed");

        // 创建红包信息
        RedPacketInfo storage rp = redPackets[id];
        rp.totalAmount = _amount;
        rp.remainingAmount = _amount;
        rp.remainingPackets = numPackets;

        rp.recipient = _recipient;
        rp.erc20 = _erc20;

        emit RedPacketCreated(id, _amount, numPackets);
    }

    function claimRedPacket(address roller, uint256 id) external returns (uint256 requestId) {
        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash,
                subId: s_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
            })
        );
        requestToSender[requestId] = roller;
        requestToRedPacketId[requestId] = id;
        emit RandomnessRequested(requestId, roller);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        address claimer = requestToSender[requestId];
        uint256 redPacketId = requestToRedPacketId[requestId];

        RedPacketInfo storage rp = redPackets[redPacketId];
        uint256 randomness = randomWords[0];
        uint256 amount = getRandomAmount(rp.remainingAmount, rp.remainingPackets, randomness);
        rp.remainingAmount -= amount;
        rp.remainingPackets--;
        hasClaimed[msg.sender][redPacketId] = true;
        IERC20 token = IERC20(rp.erc20);
        require(token.transfer(msg.sender, amount), "RedPacket: Transfer failed");

        emit RedPacketClaimed(redPacketId, claimer, amount);
    }

    function getRandomAmount(uint256 remainingAmount, uint256 remainingPackets, uint256 randomness)
        internal
        pure
        returns (uint256)
    {
        // 检查是否只剩一个红包
        // 如果只剩下一个红包，则直接返回剩余的所有金额。这是因为如果只剩一个红包，那么它应该包含所有剩余的金额。
        if (remainingPackets == 1) {
            return remainingAmount;
        }

        // 计算每个红包的最大金额：生成随机金额：最终结果在 1 到 maxAmount 之间。

        uint256 maxAmount = remainingAmount / remainingPackets * 2;
        return (randomness % maxAmount) + 1;
    }
}
