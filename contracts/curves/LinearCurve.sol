// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "contracts/interfaces/ICurves.sol";
import "lib/solmate/src/utils/SignedWadMath.sol";

contract LinearCurve is ICurves {
    uint256 public slope;
    uint256 public minMultiplier; // getFunction(0) = minMultiplier

    error LinearFunction__MIN_MULTIPLIER_MUST_GREATER_THAN_ZERO();

    constructor(uint256 _slope, uint256 _minMultiplier) {
        if (_minMultiplier == 0) revert LinearFunction__MIN_MULTIPLIER_MUST_GREATER_THAN_ZERO();
        (365 days * 20) ** _slope; // Must not panic:overflow in 20 years

        slope = _slope; // uint256 force the "strictly increasing" rule
        minMultiplier = _minMultiplier;
    }

    function getFunction(uint256 _maturity) external view returns (uint256) {
        return _getFunction(_maturity);
    }

    // [0, +infinite[ => f(x) = x * a + b
    function _getFunction(uint256 _maturity) internal view returns (uint256) {
        return _maturity * slope + minMultiplier;
    }

    // [0, +infinite[ => I(x)[m, n] = (n**a / a + n * b) - (m**a / a + m * b)
    function getAveragedIntegral(
        uint256 _maturityLow,
        uint256 _maturityHigh
    ) external view returns (uint256) {
        if (_maturityHigh == _maturityLow) return _getFunction(_maturityLow);

        uint256 slope_ = slope;
        uint256 minMultiplier_ = minMultiplier;
        uint256 Ia_ = ((_maturityHigh ** slope_) / slope_ + _maturityHigh * minMultiplier_) -
            ((_maturityLow ** slope_) / slope_ + _maturityLow * minMultiplier_);

        return Ia_ / (_maturityHigh - _maturityLow);
    }
}
