// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {ERC20} from "solmate/tokens/ERC20.sol";

contract MockUSDC is ERC20 {
    constructor() ERC20("Circle USD", "USDC", 6) {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
}
