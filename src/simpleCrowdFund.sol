// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract SimpleCrowdFund {
    // state variables
    address public owner;
    uint256 public deadline;
    uint256 public goalAmount;
    uint256 public totalContributed;
    mapping(address => uint256) public contributions;
    bool public goalReached;
    bool public fundsWithdrawn;

    // access control
    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner can authorize");
        _;
    }
    modifier afterDeadline() {
        require(block.timestamp >= deadline, "Deadline not reached");
        _;
    }

    // events
    event Contribution(address indexed contributor, uint256 amount);
    event Withdrawal(address indexed recipient, uint256 amount, uint256 timestamp);
    event Refund(address indexed recipient, uint256 amount, uint256 timestamp);


    constructor(uint256 _goalAmount){
        owner = msg.sender;
        deadline = block.timestamp + 3 minutes; // 30 days is ideal here
        goalAmount = _goalAmount;
        goalReached = false;
        fundsWithdrawn = false;
    }

    // contribute to the crowdfund
    function contribute() external payable {

        require(!goalReached, "Target reached, contributions ended");
        require(block.timestamp < deadline, "Crowdfunding has ended");
        require(msg.value > 0, "Cannot contribute zero ETH");

        contributions[msg.sender] += msg.value;
        totalContributed += msg.value;

        if (totalContributed >= goalAmount) {
            goalReached = true;
        }
        emit Contribution(msg.sender, msg.value);
    }
     // withdraw
    function withdraw() external onlyOwner afterDeadline {
        require(goalReached, "Target reached, contributions ended");
        require(!fundsWithdrawn, "Funds withdrawn already");

        fundsWithdrawn = true;
        uint256 _amount = address(this).balance;
        (bool success, ) = owner.call{value: _amount}("");
        require(success, "Transfer failed");   
        emit Withdrawal(msg.sender, _amount, block.timestamp);
    }

    // Refund if goalAmount not reached and timeline elapsed
    function refund() external afterDeadline {
        require(!goalReached, "Funding goal reached");
        uint256 amount = contributions[msg.sender];
        require(amount > 0, "No contributions was made");
        contributions[msg.sender] = 0;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        
        emit Refund(msg.sender, amount, block.timestamp);

    }

    // helper functions
    function getCountDown() external view returns(uint256){
        if (block.timestamp >= deadline){
            return 0;
        } else {
            return deadline - block.timestamp;
        }
    }

    function getContractBalance() external view returns(uint256){
        return address(this).balance;
    }
}
