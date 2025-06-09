// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract CrowdFunding {
    uint public noContributors;
    address public manager;
    uint public deadline;
    uint public raiseAmount;
    uint public target;
    uint public minContribution;
    mapping(address => uint) contributors;

    struct Request {
        string description;
        address payable receipt;
        uint value;
        bool isCompleted;
        uint noOfVoters;
        mapping(address=> bool) voters;
    }

    mapping (uint => Request) public requests;
    uint public numRequests;

    modifier onlyManager(){
         require(manager == msg.sender, "Not the manager");
        _;
    }

    modifier onlyContributor(){
        require(contributors[msg.sender]> 0,"Not a contributor");
        _;
    }

    constructor(uint _target, uint _deadline){
        manager = msg.sender;
        target = _target;
        deadline = block.timestamp + (_deadline * 1 minutes);
        minContribution =  100 wei;
    }

    function sendEth() public payable {
        require(block.timestamp >= deadline, "DeadLine not passed");
        require (msg.value >= minContribution, "Minimum amount not reached");

        contributors[msg.sender] += msg.value;
        raiseAmount += msg.value;

        if(contributors[msg.sender] == 0){
            noContributors ++;
        }
    }
    
    function getContractBalance() public view returns (uint){
        return address(this).balance;
    }

    function refund() public  {
        require(block.timestamp >= deadline, "DeadLine not passed");
        require(raiseAmount < target);
        require(contributors[msg.sender]> 0,"Not a contributor");
        // address payable user = payable(msg.sender);
        contributors[msg.sender] = 0;
    }

    function createRequest(string memory _description, address payable _receipt, uint value) public onlyManager  {
        Request storage newRequest = requests[numRequests];
        numRequests++;
        newRequest.description = _description;
        newRequest.receipt = _receipt;
        newRequest.value = value;
        newRequest.isCompleted = false;
        newRequest.noOfVoters = 0;
      }

      function voteRequest(uint requestNo) public onlyContributor {
        Request storage thisReq = requests[requestNo];
        require(!thisReq.voters[msg.sender]==false, "You have already voted");
        thisReq.voters[msg.sender] = true;
        thisReq.noOfVoters++;
      }

      function makePayment(uint _reqNo) public onlyManager {
        require(raiseAmount > target);
        Request storage thisReqs = requests[_reqNo];
        require(thisReqs.isCompleted, "Already distributed amount");
        require(thisReqs.noOfVoters > noContributors/2);
        thisReqs.receipt.transfer(thisReqs.value);
        thisReqs.isCompleted = true;
      }
}