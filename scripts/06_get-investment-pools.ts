import { ContractReceipt, ContractTransaction } from '@ethersproject/contracts';
import { BigNumber } from 'ethers';
import { ethers, run, network } from 'hardhat';
import { InvestmentPools, InvestmentPools__factory, PanacloudPlatform, PanacloudPlatform__factory } from '../typechain';

const deployedAddresses = require("../deployment/addresses.json");

async function main() {

  const [owner] = await ethers.getSigners();
  const networkName = network.name; 
  console.log("Network = ",networkName);
  
  const InvestmentPools:InvestmentPools__factory = await ethers.getContractFactory("InvestmentPools");
  const investmentPools:InvestmentPools = await InvestmentPools.attach(deployedAddresses[networkName].investmentPools);
  console.log("InvestmentPools Address to:", investmentPools.address);

  const poolcounter = await investmentPools.poolCounter();
  console.log("investmentPools.poolcounter = ",poolcounter.toString());

  const poolInfo1 = await investmentPools.poolList(0);
  console.log("investmentPools.poolInfo1 = ",poolInfo1);
  const poolInfo2 = await investmentPools.poolList(1);
  console.log("investmentPools.poolInfo2 = ",poolInfo2);
  //const poolInfo3 = await investmentPools.poolList(3);
  //console.log("investmentPools.poolInfo3 = ",poolInfo3);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
