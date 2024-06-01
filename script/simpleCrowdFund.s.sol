// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/SimpleCrowdFund.sol";

contract DeployCrowdFundScript is Script {
    function run() external {
        
        address owner = vm.addr(1);  // Owner address
        address contributor = vm.addr(2);  // Contributor address
        uint256 goalAmount = 10 ether;  

        // Emulate the owner address
        vm.startBroadcast(owner);

        // Deploy the contract
        SimpleCrowdFund crowdFund = new SimpleCrowdFund(goalAmount);
        console.log("SimpleCrowdFund contract deployed at:", address(crowdFund));
        console.log("SimpleCrowdFund owned by:", owner );

        // Stop broadcasting transactions from the owner address
        vm.stopBroadcast();

        // send ether to the contributor address
        vm.deal(contributor, 10 ether);

        // Emulate the contributor address
        vm.startBroadcast(contributor);

        // Make the contribution
        crowdFund.contribute{value: 5 ether}();
        console.log("Contribution made by:", contributor, "Amount:", 5 ether);

        // Check to avoid over contribution
        if (crowdFund.totalContributed() < goalAmount) {
            crowdFund.contribute{value: 5 ether}();
            console.log("Second contribution made by:", contributor, "Amount:", 5 ether);
        }

        // Stop broadcasting transactions from the contributor address
        vm.stopBroadcast();

        // jump the deadline
        vm.warp(block.timestamp + 2 days);

        // Emulate the owner address again
        vm.startBroadcast(owner);

        // withdraw funds
        console.log("Amount to withdraw in Ether: ", crowdFund.getContractBalance() / (10**18));
        crowdFund.withdraw();
        console.log("Funds withdrawn by:", owner );

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
