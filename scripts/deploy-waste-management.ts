import { ethers } from "hardhat";

async function main() {
  const wasteManagement = await ethers.deployContract("WasteManagement");
  await wasteManagement.waitForDeployment();

  const addressWasteManagement = await wasteManagement.getAddress();
  console.log(wasteManagement);
  console.log(addressWasteManagement);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});