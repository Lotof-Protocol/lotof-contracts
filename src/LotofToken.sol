// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {Owned} from "solmate/auth/Owned.sol";

struct AllocationParams {
    uint40 totalSupply;
    uint40 forLaunchpad;
    uint40 forEcosystem;
    uint40 forProtocolReward;
    uint40 forInitialLiquidty;
    uint40 forReserve;
}

contract LotofToken is ERC20, Owned {
    AllocationParams public allocationParams;

    constructor(AllocationParams memory _allocationParams) ERC20("Lotof Token", "LOTO", 6) Owned(msg.sender) {
        allocationParams = _allocationParams;
        _mint(address(this), _allocationParams.totalSupply - _allocationParams.forReserve);
        _mint(msg.sender, _allocationParams.forReserve);
    }

    function allocateForLaunchpad(address _launchpadAddress) public onlyOwner {
        this.transfer(_launchpadAddress, allocationParams.forLaunchpad);
        allocationParams.forLaunchpad = 0;
    }

    function allocateForEcosystem(address _stakingAddress) public onlyOwner {
        this.transfer(_stakingAddress, allocationParams.forEcosystem);
        allocationParams.forEcosystem = 0;
    }

    function allocateForProtocolReward(address _rewardAddress) public onlyOwner {
        this.transfer(_rewardAddress, allocationParams.forProtocolReward);
        allocationParams.forProtocolReward = 0;
    }

    function allocateForInitialLiquidty(address _lpHelperAddress) public onlyOwner {
        this.transfer(_lpHelperAddress, allocationParams.forInitialLiquidty);
        allocationParams.forInitialLiquidty = 0;
    }
}
