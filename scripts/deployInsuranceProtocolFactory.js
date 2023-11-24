// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const { ethers, run, network} = require("hardhat");

async function main() {
  const EHR_SystemFactory = await ethers.getContractFactory("InsuranceProtocolFactory");
  console.log("Deploying contract..........")
  const EHR_System_deploy = await EHR_SystemFactory.deploy();

  console.log(
    `Depoyed contract InsuranceProtocolFactory ${EHR_System_deploy.address}`
  );
  console.log(network.config);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
