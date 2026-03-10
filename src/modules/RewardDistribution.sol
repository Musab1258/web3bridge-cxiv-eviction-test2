// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../libraries/AresErrors.sol";

contract RewardDistribution is ReentrancyGuard {
    IERC20 public rewardToken;
    address public owner;

    mapping(uint256 => bytes32) public roundRoots;
    mapping(uint256 => mapping(address => bool)) public hasClaimed;

    constructor(address _rewardToken) {
        rewardToken = IERC20(_rewardToken);
        owner = msg.sender;
    }

    function updateRoot(uint256 roundId, bytes32 newRoot) external {
        if (msg.sender != owner) revert AresErrors.NotOwner();
        roundRoots[roundId] = newRoot;
    }

    function claim(
        uint256 roundId,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external nonReentrant {
        if (hasClaimed[roundId][msg.sender]) revert AresErrors.AlreadyClaimed();

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, amount));
        if (!MerkleProof.verify(merkleProof, roundRoots[roundId], leaf)) {
            revert AresErrors.InvalidMerkleProof();
        }

        hasClaimed[roundId][msg.sender] = true;
        require(rewardToken.transfer(msg.sender, amount), "Token transfer failed");
    }
}