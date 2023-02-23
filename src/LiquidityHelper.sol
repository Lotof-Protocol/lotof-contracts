// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {IUniswapV2Router01} from "./interface/IUniswapV2Router01.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {Owned} from "solmate/auth/Owned.sol";

contract LiquidityHelper is Owned {
    IUniswapV2Router01 public immutable exchange;
    ERC20 public immutable loto;
    ERC20 public immutable usdc;
    uint256 public immutable publicPrice;

    error WithdrawBeforeCreatingPool();

    constructor(IUniswapV2Router01 _exchange, ERC20 _loto, ERC20 _usdc, uint256 _publicPrice) Owned(msg.sender) {
        exchange = _exchange;
        loto = _loto;
        usdc = _usdc;
        publicPrice = _publicPrice;
    }

    function createPool() public onlyOwner {
        uint256 lotoWithdrawalAmount = loto.balanceOf(address(this));
        uint256 usdcWithdrawalAmount = lotoWithdrawalAmount * publicPrice / 1000;
        loto.approve(address(exchange), lotoWithdrawalAmount);
        usdc.approve(address(exchange), usdcWithdrawalAmount);
        exchange.addLiquidity(
            address(loto),
            address(usdc),
            lotoWithdrawalAmount,
            usdcWithdrawalAmount,
            0,
            0,
            owner,
            block.timestamp + 1 minutes
        );
    }

    function withdraw() public {
        address thisAddress = address(this);
        if (loto.balanceOf(thisAddress) > 0) {
            revert WithdrawBeforeCreatingPool();
        }
        usdc.transfer(owner, usdc.balanceOf(thisAddress));
    }
}
