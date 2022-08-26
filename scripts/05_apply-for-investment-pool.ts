import { ContractReceipt, ContractTransaction } from '@ethersproject/contracts';
import { BigNumber } from 'ethers';
import { ethers, run, network } from 'hardhat';
import { InvestmentPools, InvestmentPoolsManager, InvestmentPoolsManager__factory, InvestmentPools__factory, PanacloudPlatform, PanacloudPlatform__factory } from '../typechain';

const deployedAddresses = require("../deployment/addresses.json");

async function main() {

  const [owner] = await ethers.getSigners();
  const networkName = network.name; 
  console.log("Network = ",networkName);
  
  
  const InvestmentPoolsManager:InvestmentPoolsManager__factory = await ethers.getContractFactory("InvestmentPoolsManager");
  const investmentPoolsManager:InvestmentPoolsManager = await InvestmentPoolsManager.attach(deployedAddresses[networkName].investmentPoolsManager);
  console.log("InvestmentPoolsManager Address to:", investmentPoolsManager.address);

  const txt1 = await investmentPoolsManager.applyForInvestmentPool("0xa16E02E87b7454126E5E10d957A927A7F5B5d2be");

  console.log("investmentPools.createInvestmentPool Hash: ",txt1.hash);
  const txtReceipt = await txt1.wait();
  console.log("investmentPools transaction receipt: ",txtReceipt);
  
  /*
  const blockNumBefore = await ethers.provider.getBlockNumber();
  const blockBefore = await ethers.provider.getBlock(blockNumBefore);
  const timestampBefore = blockBefore.timestamp;
  console.log("blockNumBefore = ", blockNumBefore);
  console.log("blockBefore = ", blockBefore);
  console.log("timestamp = ", timestampBefore);
  */
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
