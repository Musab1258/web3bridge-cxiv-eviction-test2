// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAresGovernance {
    function proposeAndQueue(
        address target, 
        uint256 value, 
        bytes calldata data, 
        bytes calldata signature
    ) external returns (uint256);
    
    function execute(uint256 proposalId) external payable;
    function cancel(uint256 proposalId) external;
}