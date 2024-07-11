// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract BlockchainVoting {
    struct Voter {
        bool voted;
        uint vote;
    }

    struct Candidate {
        string name;
        uint voteCount;
    }

    address public owner;
    string public electionName;
    mapping(address => Voter) public voters;
    Candidate[] public candidates;
    uint public totalVotes;

    address[] public eligibleVoters;

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    constructor(string memory _name, address[] memory _eligibleVoters) {
        owner = msg.sender;
        electionName = _name;
        eligibleVoters = _eligibleVoters;
    }

    function addCandidate(string memory _name) public onlyOwner {
        candidates.push(Candidate(_name, 0));
    }

    function vote(uint _candidateIndex) public {
        require(!voters[msg.sender].voted, "You have already voted");
        require(isEligible(msg.sender), "You are not eligible to vote");

        voters[msg.sender].voted = true;
        voters[msg.sender].vote = _candidateIndex;

        candidates[_candidateIndex].voteCount += 1;
        totalVotes += 1;
    }

    function isEligible(address voter) public view returns (bool) {
        for (uint i = 0; i < eligibleVoters.length; i++) {
            if (eligibleVoters[i] == voter) {
                return true;
            }
        }
        return false;
    }

    function endElection() public onlyOwner view returns (uint winnerIndex) {
        uint maxVotes = 0;
        winnerIndex = 0;

        for (uint i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
                winnerIndex = i;
            }
        }
    }

    function getNumCandidates() public view returns (uint) {
        return candidates.length;
    }

    function getCandidate(uint index) public view returns (string memory, uint) {
        require(index < candidates.length, "Invalid candidate index");
        Candidate memory candidate = candidates[index];
        return (candidate.name, candidate.voteCount);
    }

    function getEligibleVoters() public view returns (address[] memory) {
        return eligibleVoters;
    }
}
