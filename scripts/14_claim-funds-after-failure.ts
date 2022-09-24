import { ContractReceipt, ContractTransaction } from '@ethersproject/contracts';
import { BigNumber } from 'ethers';
import { ethers, run, network } from 'hardhat';
import { InvestmentPools, InvestmentPoolsManager, InvestmentPoolsManager__factory, InvestmentPools__factory, PanacloudPlatform, PanacloudPlatform__factory, PanaCoin, PanaCoin__factory } from '../typechain';

const deployedAddresses = require("../deployment/addresses.json");

async function main() {

  const [owner, addr1, addr2] = await ethers.getSigners();
  const networkName = network.name; 
  console.log("Network = ",networkName);
  
  const investor = addr1;

  const InvestmentPools:InvestmentPools__factory = await ethers.getContractFactory("InvestmentPools");
  const investmentPools:InvestmentPools = await InvestmentPools.attach(deployedAddresses[networkName].investmentPools);
  console.log("InvestmentPools Address to:", investmentPools.address);

  const PanaCoin:PanaCoin__factory = await ethers.getContractFactory("PanaCoin");
  const panaCoin:PanaCoin = await PanaCoin.attach(deployedAddresses[networkName].panaCoin);
  console.log("PanaCoin Address to:", panaCoin.address);

  const panacoinBalanceBefore = await panaCoin.balanceOf(investmentPools.address)
  console.log("PanaCoin Balance for InvestmentPools address BEFORE = ", ethers.utils.formatEther(panacoinBalanceBefore));

  const investorBalanceBefore = await panaCoin.balanceOf(investor.address)
  console.log("Investor's PanaCoin Balance BEFORE = ", ethers.utils.formatEther(investorBalanceBefore));

  // Main claim fund function
  const txt1 = await investmentPools.connect(investor).claimFunds("0x94099942864EA81cCF197E9D71ac53310b1468D8");
  console.log("investmentPools.claimFunds Hash: ",txt1.hash);
  const txtReceipt = await txt1.wait();
  //console.log("investmentPools.claimFunds transaction receipt: ",txtReceipt);
  //

  const panacoinBalanceAfter = await panaCoin.balanceOf(investmentPools.address)
  console.log("PanaCoin Balance for InvestmentPools address AFTER = ", ethers.utils.formatEther(panacoinBalanceAfter));

  const investorBalanceAfter = await panaCoin.balanceOf(investor.address)
  console.log("Investor's PanaCoin Balance BEFORE = ", ethers.utils.formatEther(investorBalanceAfter));
  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
