// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
    

  const listAccounts = await ethers.provider.listAccounts();
  console.log("accounts are",accounts)
  const signatories = [listAccounts[0],listAccounts[1],listAccounts[2]]
  const MultiSignatureWallet = await hre.ethers.getContractFactory("MultiSignatureWallet");
  const multisig = await MultiSignatureWallet.deploy(signatories);

  await multisig.deployed();

  console.log("Multisig is deployed to address:", multisig.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
