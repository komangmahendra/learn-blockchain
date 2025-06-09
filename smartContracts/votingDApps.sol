// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingSystem {

    struct Candidate {
        uint8 id;
        bytes32 name;
        uint voteCount;
    }

    mapping(uint => Candidate) public candidate;
    mapping(address => bool) public voter;

    uint8 public candidateCount = 0;
    uint public startTime;
    uint public endTime;

    event VotedEvent(uint indexed _candidateId);

    constructor(uint timeDuration){
        startTime = block.timestamp;
        endTime = startTime + (timeDuration * 1 minutes);

        addCandidate("Candidate 1");
        addCandidate("Candidate 2");
    }

    function addCandidate(bytes32 _name) private {
        candidateCount++;
        candidate[candidateCount] = Candidate(candidateCount,_name,0);
    }

    function vote(uint _candidateId) public {
        require(block.timestamp > startTime && block.timestamp < endTime, "Voting is not allowed at this time");
        require(!voter[msg.sender], "You are already voting");
        require(_candidateId > 0 && _candidateId < 2, "You have entered invalid id");

        voter[msg.sender] = true;
        candidate[_candidateId].voteCount++;
        emit VotedEvent(_candidateId);
    }

    function getAllCandidate() public view returns (Candidate[] memory)  {
        Candidate[] memory candidateArr = new Candidate[](candidateCount);
        for(uint i=1;i<=candidateCount;i++){
            candidateArr[i-1] = candidate[i];
        }
        return candidateArr;
    }
    
    function getCurrentLeader() public view returns (Candidate memory){
        uint maxVotes = 0;
        Candidate memory lead;

        for(uint i=1; i<=candidateCount;i++){
           if(maxVotes < candidate[i].voteCount){
                maxVotes = candidate[i].voteCount;
                lead = candidate[i];
           }
        }

        return lead;
    }
  
}