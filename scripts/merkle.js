const {MerkleTree} = require("merkletreejs");
const keccak256 = require("keccak256");
const whitelist = ['0x952D2F8b1aA66Da8c5b238dd8Ad686Dab174e144','0xBE0eB53F46cd790Cd13851d5EFf43D12404d33E8'];
const leaves = whitelist.map(addr => keccak256(addr));
const merkleTree = new MerkleTree(leaves, keccak256, {sortPairs: true});
const rootHash = merkleTree.getRoot().toString('hex');
console.log(`Whitelist Merkle Root: 0x${rootHash}`);
whitelist.forEach((address) => {
  const proof =  merkleTree.getHexProof(keccak256(address));
  console.log(`Address: ${address} Proof: ${proof}`);
});