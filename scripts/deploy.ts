import { upgrades, ethers } from "hardhat";

const numberOfVersions = 1;

async function deployContract(name: string, args: any[] = []) {
  const ContractObject = await ethers.getContractFactory(name);
  const contract = await upgrades.deployProxy(ContractObject, args);
  await contract.deployed();
}

async function main() {
  for (let i = 1; i <= numberOfVersions; i++) {
    deployContract(`StoreV${i}`);
    deployContract(`ThirdbuyStoreV${i}`);
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
