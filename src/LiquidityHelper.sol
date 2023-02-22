// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {IUniswapV2Router01} from "./interface/IUniswapV2Router01.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {Owned} from "solmate/auth/Owned.sol";

contract LiquidityHelper is Owned {
    constructor(IUniswapV2Router01 _exchange, ERC20 _loto, ERC20 _usdc) Owned(msg.sender) {
        exchange = _exchange;
        loto = _loto;
        usdc = _usdc;
    }

    IUniswapV2Router01 public exchange;
    ERC20 public loto;
    ERC20 public usdc;

    function createLiquidtyPool() public onlyOwner {
        address thisAddress = address(this);
        exchange.addLiquidity(
            address(loto),
            address(usdc),
            loto.balanceOf(thisAddress),
            usdc.balanceOf(thisAddress),
            0,
            0,
            owner,
            block.timestamp + 10 minutes
        );
    }
}
