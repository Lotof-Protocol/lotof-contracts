// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {ERC20, LotofToken} from "../LotofToken.sol";

contract MockLaunchpad {
    LotofToken public immutable loto;
    ERC20 public immutable usdc;
    uint256 public immutable publicPrice;
    address public immutable usdcReciever;

    constructor(LotofToken _loto, ERC20 _usdc, uint256 _publicPrice, address _usdcReciver) {
        loto = _loto;
        usdc = _usdc;
        publicPrice = _publicPrice;
        usdcReciever = _usdcReciver;
    }

    function buyLOTO(address to, uint256 amount) public {
        usdc.transferFrom(msg.sender, usdcReciever, amount * publicPrice / 1000);
        loto.transfer(to, amount);
    }
}
