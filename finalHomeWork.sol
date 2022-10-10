// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.7;

contract Election {
    
    struct Voter {
        bool voted;   
        uint votedToWho; 
    }

    struct Nominee {
        string name;  
        uint totalVote; 
    }

    mapping(address=>Voter) public voters; 

    Nominee[] public nominees;  
    address public contractStarter;  
    
    constructor(string[] memory nomineeNames) { 
        contractStarter = msg.sender;  
        for(uint i = 0 ; i < nomineeNames.length ; i++) { 
            nominees.push(Nominee({name: nomineeNames[i], totalVote: 0}));  
        }                                                             
    }

     modifier oneVoteCheck() {  
        Voter storage voter = voters[msg.sender];  
        
        require(!voter.voted, "Voted, you can't cast another vote!");
        _;
    }

     function voting(uint preferred) external oneVoteCheck {
        require(contractStarter != msg.sender, "Invalid vote!");  

        Voter storage voter = voters[msg.sender];  
        voter.voted = true;  
        voter.votedWho = preferred; 
        nominees[preferred].totalVote++;  
     }

     function electionWinner() external view returns(string memory winnerCandidate) {
        uint moreVotes = 0;  

        for(uint i = 0 ; i < nominees.length ; i++){  
            
            if(nominees[i].totalVote > moreVotes){  
                moreVotes = nominees[i].totalVote;  
                winnerCandidate = nominees[i].name;  
            }
        }
    }

}