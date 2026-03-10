// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../libraries/AresErrors.sol";

abstract contract AttackMitigation {
    // Safety limit: 500,000 tokens
    uint256 public constant MAX_WITHDRAWAL = 500_000 * 10**18;

    function _validateTransferLimit(uint256 amount) internal pure {
        if (amount > MAX_WITHDRAWAL) {
            revert AresErrors.TransferExceedsLimit(amount, MAX_WITHDRAWAL);
        }
    }
}