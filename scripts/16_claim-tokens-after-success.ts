import { ContractReceipt, ContractTransaction } from '@ethersproject/contracts';
import { BigNumber } from 'ethers';
import { ethers, run, network } from 'hardhat';
import { APIToken, APIToken__factory, InvestmentPools, InvestmentPoolsManager, InvestmentPoolsManager__factory, InvestmentPools__factory, PanacloudPlatform, PanacloudPlatform__factory, PanaCoin, PanaCoin__factory } from '../typechain';

const deployedAddresses = require("../deployment/addresses.json");

async function main() {

  const [owner, addr1, addr2] = await ethers.getSigners();
  const networkName = network.name; 
  console.log("Network = ",networkName);
  
  const investor = addr1;

  const InvestmentPools:InvestmentPools__factory = await ethers.getContractFactory("InvestmentPools");
  const investmentPools:InvestmentPools = await InvestmentPools.attach(deployedAddresses[networkName].investmentPools);
  console.log("InvestmentPools Address to:", investmentPools.address);

  const APIToken:APIToken__factory = await ethers.getContractFactory("APIToken");
  const apiToken:APIToken = await APIToken.attach("0x94099942864EA81cCF197E9D71ac53310b1468D8");
  console.log("apiToken Address to:", apiToken.address);

  const apiTokenBalanceBefore = await apiToken.balanceOf(investmentPools.address)
  console.log("API Token Balance for InvestmentPools address BEFORE = ", ethers.utils.formatEther(apiTokenBalanceBefore));

  const investorBalanceBefore = await apiToken.balanceOf(investor.address)
  console.log("Investor's APIToken Balance BEFORE = ", ethers.utils.formatEther(investorBalanceBefore));

  // Main claim API token function
  const txt1 = await investmentPools.connect(investor).claimYourAPIToken("0x94099942864EA81cCF197E9D71ac53310b1468D8");
  console.log("investmentPools.claimYourAPIToken Hash: ",txt1.hash);
  const txtReceipt = await txt1.wait();
  //console.log("investmentPools.claimFunds transaction receipt: ",txtReceipt);
  //

  const apiTokenBalanceAfter = await apiToken.balanceOf(investmentPools.address)
  console.log("API Token Balance for InvestmentPools address AFTER = ", ethers.utils.formatEther(apiTokenBalanceAfter));

  const investorBalanceAfter = await apiToken.balanceOf(investor.address)
  console.log("Investor's API Token Balance After = ", ethers.utils.formatEther(investorBalanceAfter));

  /*
  

  
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
