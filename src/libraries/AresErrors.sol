// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library AresErrors {
    error NotAuthorized();
    error ProposalAlreadyExists();
    error ProposalNotQueued();
    error TimelockActive(uint256 availableAt);
    error TransferExceedsLimit(uint256 amount, uint256 limit);
    error TransactionFailed();
    error CannotCancelExecuted();
    error AlreadyClaimed();
    error InvalidMerkleProof();
    error NotOwner();
}