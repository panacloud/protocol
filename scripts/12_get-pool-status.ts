import { ContractReceipt, ContractTransaction } from '@ethersproject/contracts';
import { BigNumber } from 'ethers';
import { ethers, run, network } from 'hardhat';
import { InvestmentPools, InvestmentPools__factory } from '../typechain';

const deployedAddresses = require("../deployment/addresses.json");

async function main() {

  const [owner, addr1] = await ethers.getSigners();
  const networkName = network.name; 
  console.log("Network = ",networkName);
  
  const InvestmentPools:InvestmentPools__factory = await ethers.getContractFactory("InvestmentPools");
  const investmentPools:InvestmentPools = await InvestmentPools.attach(deployedAddresses[networkName].investmentPools);
  console.log("InvestmentPools Address to:", investmentPools.address);
  
  const poolFundingStatus = await investmentPools.getPoolFundingStatus("0x94099942864EA81cCF197E9D71ac53310b1468D8");
  console.log("investmentPools.getPoolFundingStatus = ",poolFundingStatus.toString());

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
