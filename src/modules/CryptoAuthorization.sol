// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "../libraries/AresErrors.sol";

abstract contract CryptoAuthorization is EIP712 {
    using ECDSA for bytes32;

    bytes32 public constant PROPOSAL_TYPEHASH = keccak256("Proposal(address target,uint256 value,bytes data,uint256 nonce)");
    
    mapping(address => uint256) public nonces;
    mapping(address => bool) public isGovernor;

    constructor(string memory name, string memory version) EIP712(name, version) {}

    function _verifyGovernorSignature(
        address target,
        uint256 value,
        bytes calldata data,
        bytes calldata signature
    ) internal returns (address) {
        address signer = _hashTypedDataV4(keccak256(abi.encode(
            PROPOSAL_TYPEHASH,
            target,
            value,
            keccak256(data),
            nonces[msg.sender]
        ))).recover(signature);

        if (!isGovernor[signer]) revert AresErrors.NotAuthorized();
        
        nonces[signer]++;
        return signer;
    }
}