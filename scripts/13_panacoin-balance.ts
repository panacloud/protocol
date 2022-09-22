import { ContractReceipt, ContractTransaction } from '@ethersproject/contracts';
import { BigNumber } from 'ethers';
import { ethers, run, network } from 'hardhat';
import { InvestmentPools, InvestmentPoolsManager, InvestmentPoolsManager__factory, InvestmentPools__factory, PanacloudPlatform, PanacloudPlatform__factory, PanaCoin, PanaCoin__factory } from '../typechain';

const deployedAddresses = require("../deployment/addresses.json");

// Transfer panacoin to the address which will apply for investment and invest in pool.
async function main() {

  const [owner, addr1] = await ethers.getSigners();
  const networkName = network.name; 
  console.log("Network = ",networkName);

  const transferTo = owner;
  
  const PanaCoin:PanaCoin__factory = await ethers.getContractFactory("PanaCoin");
  const panaCoin:PanaCoin = await PanaCoin.attach(deployedAddresses[networkName].panaCoin);
  console.log("PanaCoin Address to:", panaCoin.address);

  const panacoinBalance = await panaCoin.connect(transferTo).balanceOf(transferTo.address)
  console.log("PanaCoin Balance for transferTo address = ", ethers.utils.formatEther(panacoinBalance));

  const investorPoolPanacoinBalance = await panaCoin.connect(transferTo).balanceOf(deployedAddresses[networkName].investmentPools);
  console.log("Investment Pool's PanaCoin Balance = ", ethers.utils.formatEther(investorPoolPanacoinBalance));


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
