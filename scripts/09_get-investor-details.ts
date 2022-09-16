import { ContractReceipt, ContractTransaction } from '@ethersproject/contracts';
import { BigNumber } from 'ethers';
import { ethers, run, network } from 'hardhat';
import { InvestmentPools, InvestmentPools__factory, PanacloudPlatform, PanacloudPlatform__factory } from '../typechain';

const deployedAddresses = require("../deployment/addresses.json");

async function main() {

  const [owner, addr1] = await ethers.getSigners();
  const networkName = network.name; 
  console.log("Network = ",networkName);
  
  const investor = addr1;

  const InvestmentPools:InvestmentPools__factory = await ethers.getContractFactory("InvestmentPools");
  const investmentPools:InvestmentPools = await InvestmentPools.attach(deployedAddresses[networkName].investmentPools);
  console.log("InvestmentPools Address to:", investmentPools.address);

  const investorPool = await investmentPools.connect(investor).getInvestorDetailForAPIToken("0x94099942864EA81cCF197E9D71ac53310b1468D8",investor.address);
  console.log("investorPool = ",investorPool);
  console.log("investorPool = ",investorPool.toString());

  const investorPoolList = await investmentPools.connect(investor).getInvestorPoolList(investor.address);
  console.log("investorPoolList = ",investorPoolList);
  console.log("investorPoolList = ",investorPoolList.toString());
  

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
