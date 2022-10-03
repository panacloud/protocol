import { ContractReceipt, ContractTransaction } from '@ethersproject/contracts';
import { BigNumber } from 'ethers';
import { ethers, run, network } from 'hardhat';
import { APIToken, APIToken__factory, InvestmentPools, InvestmentPoolsManager, InvestmentPoolsManager__factory, InvestmentPools__factory, PanacloudPlatform, PanacloudPlatform__factory, PanaCoin, PanaCoin__factory } from '../typechain';

const deployedAddresses = require("../deployment/addresses.json");

async function main() {

  const [owner, addr1, addr2] = await ethers.getSigners();
  const networkName = network.name; 
  console.log("Network = ",networkName);
  
  const investor = owner; // api token developer is owner

  const InvestmentPools:InvestmentPools__factory = await ethers.getContractFactory("InvestmentPools");
  const investmentPools:InvestmentPools = await InvestmentPools.attach(deployedAddresses[networkName].investmentPools);
  console.log("InvestmentPools Address to:", investmentPools.address);

  // Must be called by API developer
  const txt1 = await investmentPools.connect(investor).claimMilestonePayment("0x94099942864EA81cCF197E9D71ac53310b1468D8");
  console.log("investmentPools.claimYourAPIToken Hash: ",txt1.hash);
  const txtReceipt = await txt1.wait();

  const investmentPool = await investmentPools.getInvestmentPool("0x94099942864EA81cCF197E9D71ac53310b1468D8");
  console.log("investmentPool = ",investmentPool.toString());
  
  //const investmentPoolDetails = await investmentPools.getPoolInvestmentDetails(poolInfo1.apiToken);
  const investmentPoolDetails = await investmentPools.getPoolInvestmentDetails("0x94099942864EA81cCF197E9D71ac53310b1468D8");
  console.log("investmentPoolDetails = ",investmentPoolDetails.toString());
  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
