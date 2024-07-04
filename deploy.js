const ethers = require("ethers");
require('dotenv').config();

async function main() {
  // Provide the network URL or provider object
  const provider = ethers.getDefaultProvider(); // For local Hardhat network

  // Get the wallet signer
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY); // Replace with your private key
  const signer = wallet.connect(provider);

  // Get the contract factory
  const contractFactory = new ethers.ContractFactory(
    // Load the contract ABI from the compiled artifacts
    require("./artifacts/contracts/MyNFT.sol/MyNFT.json"),
    signer
  );

  // Deploy the contract
  const contract = await contractFactory.deploy();
  const contractAddress = contract.address;

  console.log("Contract deployed to:", contractAddress);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
