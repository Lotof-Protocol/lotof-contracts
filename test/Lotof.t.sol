// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import "../src/LotofToken.sol";
import "../src/StakingPool.sol";
import "../src/LiquidityHelper.sol";

contract LotofTest is Test {
    LotofToken public loto;
    StakingPool public pool;
    // LiquidityHelper public helper;
    AllocationParams public allocation;

    address public dev;

    uint40 public LOTO_TOTAL_SUPPLY = _toUnits(1000_000);
    uint40 public LOTO_FOR_LAUNCHPAD = _toUnits(200_000);
    uint40 public LOTO_FOR_ECOSYSTEM = _toUnits(350_000);
    uint40 public LOTO_FOR_PROTOCOL_REWARD = _toUnits(100_000);
    uint40 public LOTO_FOR_INITIAL_LIQUIDITY = _toUnits(50_000);
    uint40 public LOTO_FOR_RESERVE = _toUnits(300_000);

    function setUp() public {
        allocation = AllocationParams(
            LOTO_TOTAL_SUPPLY,
            LOTO_FOR_LAUNCHPAD,
            LOTO_FOR_ECOSYSTEM,
            LOTO_FOR_PROTOCOL_REWARD,
            LOTO_FOR_INITIAL_LIQUIDITY,
            LOTO_FOR_RESERVE
        );
        dev = makeAddr("dev");
        hoax(dev);
        loto = new LotofToken(allocation);
        pool = new StakingPool(loto);
        hoax(dev);
        loto.allocateForEcosystem(address(pool));
    }

    function testInitBalance() public {
        assertEq(loto.balanceOf(dev), LOTO_FOR_RESERVE);
        assertEq(loto.balanceOf(address(pool)), LOTO_FOR_ECOSYSTEM);
    }

    function testStakingPool(uint40 amountToDeposit) public {
        vm.assume(amountToDeposit > 0 && amountToDeposit <= LOTO_FOR_RESERVE);
        assertEq(pool.totalAssets(), 0);
        vm.startPrank(dev);
        loto.approve(address(pool), amountToDeposit);
        pool.deposit(amountToDeposit, dev);
        vm.stopPrank();
        assertEq(pool.totalAssets(), amountToDeposit);
        assertEq(pool.maxWithdraw(dev), amountToDeposit);
        assertEq(pool.maxRedeem(dev), amountToDeposit);
    }

    function _toUnits(uint40 amount) private pure returns (uint40) {
        return amount * 10 ** 6;
    }
}
