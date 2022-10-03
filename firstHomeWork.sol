// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.7;

contract EtherStore { 
    
    address public _owner;    
    uint256 public balance;  
    
    constructor() {
        _owner = msg.sender;               
    }
    
    receive() payable external { 
        balance += msg.value;    
    }

    modifier withdrawModifier(uint amount){
        require(msg.sender == _owner, "Only owner can withdraw");  
        require(amount <= balance, "Insufficient funds");  
        _;
    }
    
    function withdraw(uint amount, address payable destAddr) public withdrawModifier(amount)  {   
        destAddr.transfer(amount); 
        balance -= amount;  
    }
}