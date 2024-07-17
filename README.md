VoteCrypt 
A Transparent Voting System 


The MerkleVoting smart contract was written using Solidity code and deployed on the Hedera blockchain. The contract utilizes two main structs, a Voter struct and a Candidate struct. The smart contract has an owner that can add candidates and administer the election phases. 
The Hedera blockchain was chosen due to its significant transaction processing capabilities. Using Hedera would make the voting process scalable and financially feasible for any election. Hedera’s KYC capabilities (flags) could further enhance the voter experience. 
By utilizing merkle trees for voter eligibility verification, the smart contract provides for an efficient way of handling large amounts of voter data. Using the setMerkleRoot function, the contract owner can set the merkle root (generated offline) for the merkle proofs to be checked against. 
When voting, the voter has to submit the merkle proof (to be generated in the UI backend) together with the candidate number that should receive the vote. The merkle proof is then checked against the merkle root using OpenZeppelin’s MerkleProof contract
