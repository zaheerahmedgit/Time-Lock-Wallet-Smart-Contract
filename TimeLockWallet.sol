// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

contract TimeLockWallet {

    // Data structure to store deposit info
    struct Deposit {
        address user;
        uint256 amount;
        uint256 depositTime;
        uint256 lockTime;
    }

    mapping(address => Deposit) public Deposits; //mapping to store deposits that depositors deposit

    // Events to emit when functions will be called
    event DepositedAndLocked(address indexed user, uint256 amount, uint256 lockTime);
    event AssetWithdrawn(address indexed user, uint256 amount, uint256 remainingBalance);


    // Function to deposit and lock assets for a specific time period
    function deposit(uint256 _amount, uint256 _lockTime) public payable {
        require(msg.value > 0, "Amount must be greater than zero");
        require(msg.value == _amount, "Deposit balance not equal to amount");
        require(msg.sender != address(0), "Invalid sender address");

        Deposits[msg.sender].user = msg.sender;
        Deposits[msg.sender].amount += _amount;
        Deposits[msg.sender].depositTime = block.timestamp;
        Deposits[msg.sender].lockTime = block.timestamp + _lockTime;

        emit DepositedAndLocked(msg.sender, _amount, Deposits[msg.sender].lockTime);
    }


    // Function to withdraw desired amount from wallet
    function withdraw(uint256 _amount) public {
        require(msg.sender == Deposits[msg.sender].user, "You are not the owner of these assets");
        require(_amount > 0 && _amount <= Deposits[msg.sender].amount, "Not enough balance in account to withdraw");
        require(block.timestamp >= Deposits[msg.sender].lockTime, "Your assets are locked in the account");

        uint256 remainingAmount = Deposits[msg.sender].amount - _amount;
        Deposits[msg.sender].amount = remainingAmount;

        payable(msg.sender).transfer(_amount);

        emit AssetWithdrawn(msg.sender, _amount, remainingAmount);
    }
}
