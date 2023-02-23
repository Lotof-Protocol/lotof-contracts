// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import "../src/LotofToken.sol";
import "../src/StakingPool.sol";
import "../src/mock/MockExchange.sol";
import "../src/mock/MockLaunchpad.sol";
import "../src/mock/MockUSDC.sol";
import "../src/LiquidityHelper.sol";

contract LotofTest is Test {
    LotofToken public loto;
    StakingPool public pool;
    LiquidityHelper public helper;
    IUniswapV2Router01 public exchange;
    MockLaunchpad public launchpad;
    MockUSDC public usdc;
    AllocationParams public allocation;

    address public dev;
    address public investor;

    uint40 public LOTO_TOTAL_SUPPLY = _toUnits(1000_000);
    uint40 public LOTO_FOR_LAUNCHPAD = _toUnits(200_000);
    uint40 public LOTO_FOR_ECOSYSTEM = _toUnits(350_000);
    uint40 public LOTO_FOR_PROTOCOL_REWARD = _toUnits(100_000);
    uint40 public LOTO_FOR_INITIAL_LIQUIDITY = _toUnits(100_000);
    uint40 public LOTO_FOR_RESERVE = _toUnits(250_000);
    uint256 public PUBLIC_PRICE = 1500; // price = 1.5 USDC

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
        investor = makeAddr("investor");
        vm.startPrank(dev);
        loto = new LotofToken(allocation);
        usdc = new MockUSDC();
        pool = new StakingPool(loto);
        exchange = new MockExchange();
        helper = new LiquidityHelper(exchange, loto, usdc, PUBLIC_PRICE);
        launchpad = new MockLaunchpad(loto, usdc, PUBLIC_PRICE, address(helper));
        loto.allocateForEcosystem(address(pool));
        loto.allocateForInitialLiquidty(address(helper));
        loto.allocateForLaunchpad(address(launchpad));
        vm.stopPrank();
    }

    function testInitBalance() public {
        assertEq(loto.balanceOf(dev), LOTO_FOR_RESERVE);
        assertEq(loto.balanceOf(address(pool)), LOTO_FOR_ECOSYSTEM);
        assertEq(loto.balanceOf(address(helper)), LOTO_FOR_INITIAL_LIQUIDITY);
        assertEq(loto.balanceOf(address(launchpad)), LOTO_FOR_LAUNCHPAD);
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

    function testLiquidityHelper() public {
        uint256 totalFundUSDC = LOTO_FOR_LAUNCHPAD * PUBLIC_PRICE / 1000;
        vm.startPrank(investor);
        usdc.mint(investor, totalFundUSDC);
        usdc.approve(address(launchpad), type(uint256).max);
        launchpad.buyLOTO(investor, LOTO_FOR_LAUNCHPAD);
        assertEq(loto.balanceOf(address(helper)), LOTO_FOR_INITIAL_LIQUIDITY);
        assertEq(usdc.balanceOf(address(helper)), totalFundUSDC);
        vm.stopPrank();

        vm.startPrank(dev);
        helper.createPool();
        assertEq(loto.balanceOf(address(helper)), 0);
        assertEq(usdc.balanceOf(address(helper)), totalFundUSDC - LOTO_FOR_INITIAL_LIQUIDITY * PUBLIC_PRICE / 1000);
        assertEq(usdc.balanceOf(dev), 0);
        helper.withdraw();
        assertEq(usdc.balanceOf(dev), (LOTO_FOR_LAUNCHPAD - LOTO_FOR_INITIAL_LIQUIDITY) * PUBLIC_PRICE / 1000);
        vm.stopPrank();
    }

    function _toUnits(uint40 amount) private pure returns (uint40) {
        return amount * 10 ** 6;
    }
}
