import { ContractReceipt, ContractTransaction } from '@ethersproject/contracts';
import { BigNumber } from 'ethers';
import { ethers, run, network } from 'hardhat';
import { InvestmentPools, InvestmentPoolsManager, InvestmentPoolsManager__factory, InvestmentPools__factory, PanacloudPlatform, PanacloudPlatform__factory } from '../typechain';

const deployedAddresses = require("../deployment/addresses.json");

async function main() {

  const [owner, addr1] = await ethers.getSigners();
  const networkName = network.name; 
  console.log("Network = ",networkName);
  
  const investor = addr1;
  
  const InvestmentPools:InvestmentPools__factory = await ethers.getContractFactory("InvestmentPools");
  const investmentPools:InvestmentPools = await InvestmentPools.attach(deployedAddresses[networkName].investmentPools);
  console.log("InvestmentPools Address to:", investmentPools.address);

  const blockNumBefore = await ethers.provider.getBlockNumber();
  const blockBefore = await ethers.provider.getBlock(blockNumBefore);
  const timestampBefore = blockBefore.timestamp;
  console.log("blockNumBefore = ", blockNumBefore);
  console.log("blockBefore = ", blockBefore);
  console.log("timestamp = ", timestampBefore);

  const txt1 = await investmentPools.connect(investor).applyForInvestmentPool("0x94099942864EA81cCF197E9D71ac53310b1468D8");

  console.log("investmentPools.applyForInvestmentPool Hash: ",txt1.hash);
  const txtReceipt = await txt1.wait();
  console.log("investmentPools.applyForInvestmentPool transaction receipt: ",txtReceipt);
  
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
