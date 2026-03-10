# ARES Protocol: Architecture and Specification Document

## 1. Executive Summary

A $500 million treasury may be safely managed with the help of the ARES Protocol, a decentralized governance and treasury administration system. Defense-in-depth, modularity, and cryptographic security are given top priority in the architecture. The approach makes sure that no single weakness can jeopardize the entire protocol by dividing worries into five different smart contracts. The high-level design, state flow, component interactions, and technical requirements that comprise the ARES ecosystem are described in this document.

## 2. Core System Components

Each of the five specialized modules that make up the protocol has access controls that are strictly defined and communicate with one another through secure internal interfaces.

* **TransactionProposals.sol:** This is where governance begins. It takes care of all governance proposal generation, tracking, and lifecycle management. Proposals flow linearly between states in a state machine model that it rigorously enforces: `Pending` $\rightarrow$ `Active` $\rightarrow$ `Queued` $\rightarrow$ `Executed`. It ensures unchangeable historical accuracy and avoids logic loops by specifically blocking state reversions (e.g., preventing a `Executed` proposal from being `Canceled`).

* **Timelock.sol:** This contract imposes a necessary 48-hour hold on all accepted proposals in order to safeguard the treasury against abrupt, malevolent governance takeovers. A proposal is queued here once it passes. In order to provide the community time to examine and respond to impending transactions, `Timelock.sol` stops any payload from being executed until `block.timestamp` strictly surpasses the queuing time + the 48-hour delay.

* **CryptoAuthorization.sol:** In order to approve on-chain activities without the need for gas-intensive voting, this module manages off-chain signature verification. By linking signatures to our unique chain ID and contract address, it prevents cross-chain replays and domain collisions by implementing the EIP-712 standard for typed data hashing. It keeps a strict `mapping(address => uint252)` for nonces to thwart common signature replay attacks and uses OpenZeppelin's ECDSA library to enforce lower-s values, preventing signature malleability.

* **RewardDistribution.sol:** This contract leverages Merkle Trees for high-efficiency token distribution, enabling thousands of users to claim prizes with low gas overhead. It employs a hierarchical state architecture: `mapping(uint256 => mapping(address => bool)) public hasClaimed` to handle numerous, sequential reward rounds (root updates) without locking out prior claimants or permitting double claims.

* **AttackMitigation.sol:** The last line of defense is this contract. It applies a maximum transfer restriction and a global circuit breaker. This module mathematically prevents large treasury draining in a single transaction by intercepting calls during the execute phase of any proposal to ensure that the outflow of funds does not beyond predetermined safety levels.

## 3. Actor Roles and Access Control

To limit sensitive functions, the protocol uses role-based access control:

* **Governors:** The `GOVERNOR_ROLE` is assigned to authorized addresses. They can queue up successful votes, submit signed EIP-712 proposals, and cancel pending proposals they started.

* **Claimants:** Standard users are eligible to receive token distributions through the Merkle tree verification scheme. Only the `RewardDistribution` contract interacts with them.

## 4. Primary Workflows & System State Flow

The architecture follows a strict, unidirectional flow of execution to ensure predictability.

### A. Submitting and Executing a Proposal

*   **Sign:** A Governor generates an EIP-712 signature containing the proposal payload (target address, transfer value, calldata) off-chain.

*   **Propose:** A user or Governor calls `TransactionProposals.propose(payload, signature)`. The contract verifies the nonce, recovers the signer via `CryptoAuthorization`, ensures the signer has the `GOVERNOR_ROLE`, and sets the state to `Queued`.

*   **Wait:** The system automatically enforces the 48-hour delay within `Timelock.sol`.

*   **Execute:** After 48 hours, any user can call `Timelock.execute(proposalId)`. The system verifies the timestamp, passes the payload through `AttackMitigation.sol` to check the withdrawal limits, and dispatches the transaction, updating the state to `Executed`.

### B. Claiming Rewards

*   **Fetch Proof:** The Claimant retrieves their specific Merkle proof and claim amount from the off-chain dApp interface.

*   **Claim:** The Claimant calls `RewardDistribution.claim(uint256 roundId, uint256 amount, bytes32[] calldata merkleProof)`.

*   **Verification:** The contract hashes `msg.sender` and `amount` to create the leaf, then calls OpenZeppelin's `MerkleProof.verify()`.

*   **Payout:** If valid, the contract updates `hasClaimed[roundId][msg.sender] = true` and transfers the tokens.
