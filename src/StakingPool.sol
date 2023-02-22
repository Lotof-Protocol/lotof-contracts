// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {ERC20, ERC4626} from "solmate/mixins/ERC4626.sol";

contract StakingPool is ERC4626 {
    constructor(ERC20 _loto) ERC4626(_loto, "Staked LOTO", "stLOTO") {}

    uint256 private _totalStakedAmount;

    function totalAssets() public view override returns (uint256) {
        return _totalStakedAmount;
    }

    function beforeWithdraw(uint256 assets, uint256 shares) internal override {
        _totalStakedAmount -= assets;
        ERC4626.beforeWithdraw(assets, shares);
    }

    function afterDeposit(uint256 assets, uint256 shares) internal override {
        _totalStakedAmount += assets;
        ERC4626.afterDeposit(assets, shares);
    }
}
