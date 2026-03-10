// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IAresGovernance.sol";
import "../libraries/AresErrors.sol";
import "../modules/CryptoAuthorization.sol";
import "../modules/AttackMitigation.sol";
import "../modules/Timelock.sol";

contract TransactionProposals is IAresGovernance, CryptoAuthorization, AttackMitigation, Timelock {
    enum State { None, Queued, Executed, Canceled }

    struct Proposal {
        address target;
        uint256 value;
        bytes data;
        State state;
        uint256 queuedAt;
    }

    mapping(uint256 => Proposal) public proposals;

    event ProposalQueued(uint256 indexed proposalId);
    event ProposalExecuted(uint256 indexed proposalId);
    event ProposalCanceled(uint256 indexed proposalId);

    constructor() CryptoAuthorization("ARES_Protocol", "1") {
        isGovernor[msg.sender] = true; 
    }

    function proposeAndQueue(
        address target,
        uint256 value,
        bytes calldata data,
        bytes calldata signature
    ) external override returns (uint256) {
        _verifyGovernorSignature(target, value, data, signature);

        uint256 proposalId = uint256(keccak256(abi.encode(target, value, data)));
        if (proposals[proposalId].state != State.None) revert AresErrors.ProposalAlreadyExists();

        proposals[proposalId] = Proposal({
            target: target,
            value: value,
            data: data,
            state: State.Queued,
            queuedAt: block.timestamp
        });

        emit ProposalQueued(proposalId);
        return proposalId;
    }

    function execute(uint256 proposalId) external payable override {
        Proposal storage proposal = proposals[proposalId];
        
        if (proposal.state != State.Queued) revert AresErrors.ProposalNotQueued();
        
        _checkTimelock(proposal.queuedAt);
        _validateTransferLimit(proposal.value);

        proposal.state = State.Executed;

        (bool success, ) = proposal.target.call{value: proposal.value}(proposal.data);
        if (!success) revert AresErrors.TransactionFailed();

        emit ProposalExecuted(proposalId);
    }

    function cancel(uint256 proposalId) external override {
        if (!isGovernor[msg.sender]) revert AresErrors.NotAuthorized();
        
        Proposal storage proposal = proposals[proposalId];
        if (proposal.state != State.Queued) revert AresErrors.CannotCancelExecuted();

        proposal.state = State.Canceled;
        emit ProposalCanceled(proposalId);
    }

    receive() external payable {}
}