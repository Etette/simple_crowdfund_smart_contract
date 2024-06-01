// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/SimpleCrowdFund.sol";

contract SimpleCrowdFundTest is Test {
    SimpleCrowdFund crowdFund;
    address owner;
    address contributor;

    function setUp() public {
        owner = vm.addr(1);
        contributor = vm.addr(2);
        vm.prank(owner);
        crowdFund = new SimpleCrowdFund(10 ether);
    }

    function testContribution() public {
        vm.deal(contributor, 10 ether);
        vm.prank(contributor);
        crowdFund.contribute{value: 5 ether}();

        assertEq(crowdFund.contributions(contributor), 5 ether);
        assertEq(crowdFund.totalContributed(), 5 ether);
    }

    function testWithdrawFunds() public {
        vm.deal(contributor, 10 ether);
        vm.prank(contributor);
        crowdFund.contribute{value: 10 ether}();

        vm.warp(block.timestamp + 2 days);
        vm.prank(owner);
        crowdFund.withdraw();

        assertEq(address(owner).balance, 10 ether);
    }

    function testRefund() public {
        vm.deal(contributor, 5 ether);
        vm.prank(contributor);
        crowdFund.contribute{value: 5 ether}();

        vm.warp(block.timestamp + 2 days);
        vm.prank(contributor);
        crowdFund.refund();

        assertEq(address(contributor).balance, 5 ether);
        assertEq(crowdFund.contributions(contributor), 0);
    }

    function testFuzzContribute(uint256 amount) public {
        vm.assume(amount > 0 && amount < 100 ether);
        vm.deal(contributor, amount);
        vm.prank(contributor);
        crowdFund.contribute{value: amount}();

        assertEq(crowdFund.contributions(contributor), amount);
    }
}
