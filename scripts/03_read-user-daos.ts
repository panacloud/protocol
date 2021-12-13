import { ContractReceipt, ContractTransaction } from '@ethersproject/contracts';
import { ethers, run, network } from 'hardhat';
import { PanacloudPlatform, PanacloudPlatform__factory } from '../typechain';

const deployedAddresses = require("../deployment/addresses.json");

async function main() {

  const [owner] = await ethers.getSigners();
  const networkName = network.name; 
  console.log("Network = ",networkName);
  const PanacloudPlatform:PanacloudPlatform__factory = await ethers.getContractFactory("PanacloudPlatform");
  const panacloudPlatform:PanacloudPlatform = await PanacloudPlatform.attach(deployedAddresses[networkName].panacloudPlatform);
  console.log("PanacloudPlatform Address to:", panacloudPlatform.address);

  const tokenAndDaoAddresses:{apiDao:string, apiToken:string}[] = await panacloudPlatform.getDAOAndTokenForOwner(owner.address);
  console.log("Token And Dao Addresses: ",tokenAndDaoAddresses);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
