// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library SignedSafeMath {
    int256 constant private _INT256_MIN = -2**255;

    function toUInt256(int256 a) internal pure returns (uint256) {
        require(a >= 0, "Integer < 0");
        return uint256(a);
    }
}
