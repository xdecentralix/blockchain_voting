// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleVoting {
    struct Voter {
        bool voted;
        uint256 vote;
    }

    struct Candidate {
        string name;
        uint256 voteCount;
    }

    address public owner;
    string public electionName;
    mapping(address => Voter) public voters;
    Candidate[] public candidates;
    uint256 public totalVotes;
    bool public electionActive = false;
    uint256 public electionStart;
    uint256 public electionDuration;
    uint256 public electionEnd;
    bytes32 public merkleRoot;

    constructor(string memory _electionName) {
        owner = msg.sender;
        electionName = _electionName;
    }

    // Setup of the election
    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function addCandidates(string[] memory _names) public onlyOwner {
        require (!electionActive, "Election has already started");
        for (uint256 i = 0; i < _names.length; i++) {
            candidates.push(Candidate(_names[i], 0));
        }
    }

    // Start the election
    function startElection(uint256 _electionDuration) public onlyOwner {
        require(!electionActive);
        require(merkleRoot != 0, "Merkle root is not set");
        require(candidates.length > 0, "No candidates added");
        electionActive = true;
        electionStart = block.timestamp;
        electionDuration = _electionDuration;
        electionEnd = electionStart + _electionDuration;
    }

    // Voting
    function vote(bytes32[] memory _merkleProof, uint256 _candidateIndex) public {
        require(electionEnd > block.timestamp, "Election is over");
        require(_candidateIndex < candidates.length, "Invalid candidate index");
        require(!voters[msg.sender].voted, "You have already voted");
        bytes32 merkleLeaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof, merkleRoot, merkleLeaf), "You are not eligible to vote");
        
        voters[msg.sender].voted = true;
        voters[msg.sender].vote = _candidateIndex;

        candidates[_candidateIndex].voteCount += 1;
        totalVotes += 1;
    }

    // End Election
    function endElection() public onlyOwner returns (uint256 winnerIndex) {
        require(block.timestamp >= electionEnd, "Election is still ongoing");
        require(electionActive, "Election has not started");
        uint maxVotes = 0;
        winnerIndex = 0;

        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
                winnerIndex = i;
            }
        }
        electionActive = false;
        return winnerIndex;
    }

    // Helper Functions & Modifiers
    function getNumCandidates() public view returns (uint256) {
        return candidates.length;
    }

    function getCandidate(uint256 index) public view returns (string memory, uint256) {
        require(index < candidates.length, "Invalid candidate index");
        Candidate memory candidate = candidates[index];
        return (candidate.name, candidate.voteCount);
    }

    function getCandidates() public view returns (Candidate[] memory) {
        return candidates;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
}
