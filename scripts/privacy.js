const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');
const crypto = require('crypto');

// Example of a secret key (must be kept secret)
const SECRET_KEY = 'this-is-a-very-secret-key-that-needs-to-be-32'; // Ensure this is exactly 32 bytes

const whitelist = [
    '0x952D2F8b1aA66Da8c5b238dd8Ad686Dab174e144',
    '0xBE0eB53F46cd790Cd13851d5EFf43D12404d33E8',
    '0x725dbd101b28576c5BFf7f5FdB13942043671711',
    '0x1EB67525774407Be694864dbF6c4DC46fB49a3fe'
];

const leaves = whitelist.map(addr => keccak256(addr));
const merkleTree = new MerkleTree(leaves, keccak256, { sortPairs: true });
const rootHash = merkleTree.getRoot().toString('hex');
console.log(`Whitelist Merkle Root: 0x${rootHash}`);

whitelist.forEach((address) => {
    const proof = merkleTree.getHexProof(keccak256(address));
    console.log(`Address: ${address} Proof: ${proof}`);
});

// Ensure the secret key is 32 bytes long
function getKey(key) {
    return crypto.createHash('sha256').update(String(key)).digest('base64').substr(0, 32);
}

// Function to encrypt a vote
function encryptVote(vote, secretKey) {
    const iv = crypto.randomBytes(16); // Initialization vector
    const cipher = crypto.createCipheriv('aes-256-cbc', Buffer.from(secretKey), iv);
    let encrypted = cipher.update(vote, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    return iv.toString('hex') + encrypted; // Prepend IV for decryption
}

// Example of encrypting a vote
const vote = '1'; // Vote for candidate index 1
const key = getKey(SECRET_KEY);
const encryptedVote = encryptVote(vote, key);
console.log(`Encrypted Vote: ${encryptedVote}`);

// To verify decryption (not part of the actual encryption process)

function decryptVote(encryptedVote, secretKey) {
    const iv = Buffer.from(encryptedVote.slice(0, 32), 'hex');
    const encryptedText = Buffer.from(encryptedVote.slice(32), 'hex');
    const decipher = crypto.createDecipheriv('aes-256-cbc', Buffer.from(secretKey), iv);
    let decrypted = decipher.update(encryptedText, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    return decrypted;
}

console.log(`Decrypted Vote: ${decryptVote(encryptedVote, key)}`);
