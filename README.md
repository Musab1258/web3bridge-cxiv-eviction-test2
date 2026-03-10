# ARES Protocol

ARES is an enterprise-grade, decentralized governance protocol designed to manage high-value treasuries with a focus on defense-in-depth and cryptographic security. 

## Security Features

- **48-Hour Timelock**: Prevents "flash" governance attacks.
- **EIP-712 Signatures**: Secure, off-chain authorization with replay protection.
- **Merkle Rewards**: Gas-efficient token distribution for thousands of users.
- **Single Withdrawal Limit**: Hard caps on single-transaction outflows.

## How to Test

### Prerequisites

*   Foundry installed.

## Installation

```bash
# Install OpenZeppelin dependencies
forge install OpenZeppelin/openzeppelin-contracts
```

## Build & Test

```bash
# Compile all contracts
forge build

# Run the 8 Mandatory Security Exploit Tests
forge test --match-contract AresExploitsTest -vvvv
```

### Security Test Suite

The project includes 8 comprehensive negative test cases proving the protocol's resilience:

*   **Premature Execution:** Reverts if called before 48-hour delay.
*   **Unauthorized Cancel:** Blocks non-governor cancellation attempts.
*   **Invalid Signature:** Rejects signatures from unauthorized keys.
*   **Signature Replay:** Prevents reuse of valid signatures via nonces.
*   **Proposal Replay:** Ensures identical payloads generate unique IDs.
*   **Front-running:** Protects against state changes during race conditions.
*   **Double Claim:** Blocks multiple reward withdrawals in a single round.
*   **Reentrancy:** Neutralizes recursive calls during fund transfers.