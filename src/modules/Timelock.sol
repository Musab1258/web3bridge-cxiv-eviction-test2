// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../libraries/AresErrors.sol";

abstract contract Timelock {
    uint256 public constant DELAY = 48 hours;

    function _checkTimelock(uint256 queuedAt) internal view {
        if (block.timestamp < queuedAt + DELAY) {
            revert AresErrors.TimelockActive(queuedAt + DELAY);
        }
    }
}