// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

//TODO
import "forge-std/console.sol";

import "contracts/interfaces/ICurves.sol";

contract LinearPlateauCurve is ICurves {
    uint256 public slope;
    uint256 public minMultiplier; // getFunction(0) = minMultiplier
    uint256 public plateauLevel; // getFunction(0) = minMultiplier

    error LinearFunction__MIN_MULTIPLIER_MUST_GREATER_THAN_ZERO();

    constructor(uint256 _slope, uint256 _minMultiplier, uint256 _plateauLevel) {
        if (_minMultiplier == 0) revert LinearFunction__MIN_MULTIPLIER_MUST_GREATER_THAN_ZERO();
        _plateauLevel ** _slope; // Must not panic:overflow at plateau

        slope = _slope; // uint256 force the "strictly increasing" rule
        minMultiplier = _minMultiplier;
        plateauLevel = _plateauLevel;
    }

    function getFunction(uint256 _maturity) external view returns (uint256) {
        return _getFunction(_maturity);
    }

    // [0, p]         => f(x) =  x * a + b
    // ]p, +infinite[ => f(x) =  p * a + b
    function _getFunction(uint256 _maturity) internal view returns (uint256) {
        if (_maturity > plateauLevel) return plateauLevel * slope + minMultiplier;
        return _maturity * slope + minMultiplier;
    }

    // [0, p]         => Ia(x)[m, n] = (n**a / a + n * b) - (m**a / a + m * b)
    // ]p, +infinite[ => Ib(x)[m, n] = ((p * a + b) * n) - ((p * a + b) * m) = (p * a + b) * (n - m)
    function getAveragedIntegral(
        uint256 _maturityLow,
        uint256 _maturityHigh
    ) external view returns (uint256) {
        if (_maturityHigh == _maturityLow) return _getFunction(_maturityLow);
        console.log("--)))");

        uint256 plateauLevel_ = plateauLevel;
        uint256 slope_ = slope;
        uint256 minMultiplier_ = minMultiplier;

        if (_maturityHigh <= plateauLevel_) {
            uint256 Ia_ = ((_maturityHigh ** slope_) / slope_ + _maturityHigh * minMultiplier_) -
                ((_maturityLow ** slope_) / slope_ + _maturityLow * minMultiplier_);

            return Ia_ / (_maturityHigh - _maturityLow);
        } else if (_maturityLow >= plateauLevel_) {
            uint256 Ib_ = (plateauLevel_ * slope_ + minMultiplier_) *
                (_maturityHigh - _maturityLow);

            return Ib_ / (_maturityHigh - _maturityLow);
        } else {
            uint256 Ia_ = ((plateauLevel_ ** slope_) / slope_ + plateauLevel_ * minMultiplier_) -
                ((_maturityLow ** slope_) / slope_ + _maturityLow * minMultiplier_);

            uint256 Ib_ = (plateauLevel_ * slope_ + minMultiplier_) *
                (_maturityHigh - plateauLevel_);

            return (Ia_ + Ib_) / (_maturityHigh - _maturityLow);
        }
    }
}
