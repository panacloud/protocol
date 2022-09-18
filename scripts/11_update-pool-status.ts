import { ContractReceipt, ContractTransaction } from '@ethersproject/contracts';
import { BigNumber } from 'ethers';
import { ethers, run, network } from 'hardhat';
import { InvestmentPools, InvestmentPoolsManager, InvestmentPoolsManager__factory, InvestmentPools__factory, PanacloudPlatform, PanacloudPlatform__factory, PanaCoin, PanaCoin__factory } from '../typechain';

const deployedAddresses = require("../deployment/addresses.json");

async function main() {

  const [owner, addr1] = await ethers.getSigners();
  const networkName = network.name; 
  console.log("Network = ",networkName);
  
  const InvestmentPools:InvestmentPools__factory = await ethers.getContractFactory("InvestmentPools");
  const investmentPools:InvestmentPools = await InvestmentPools.attach(deployedAddresses[networkName].investmentPools);
  console.log("InvestmentPools Address to:", investmentPools.address);

  //1=In Progress, 2=Successfull, 3=Failed 
  const statusToBeSet = 2;
  const txt1 = await investmentPools.updatetPoolFundingStatus("0x94099942864EA81cCF197E9D71ac53310b1468D8",statusToBeSet);

  console.log("investmentPools.updatetPoolFundingStatus Hash: ",txt1.hash);
  const txtReceipt = await txt1.wait();
  console.log("investmentPools.updatetPoolFundingStatus transaction receipt: ",txtReceipt);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
