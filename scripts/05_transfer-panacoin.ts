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

  const transferTo = addr1;
  
  const PanaCoin:PanaCoin__factory = await ethers.getContractFactory("PanaCoin");
  const panaCoin:PanaCoin = await PanaCoin.attach(deployedAddresses[networkName].panaCoin);
  console.log("PanaCoin Address to:", panaCoin.address);

  const txt1 = await panaCoin.transfer(transferTo.address, ethers.utils.parseEther("100"));
  console.log("panaCoin.transfer Hash: ",txt1.hash);
  const txtReceipt = await txt1.wait();
  console.log("panaCoin.transfer( receipt: ",txtReceipt);

  const panacoinBalance = await panaCoin.connect(transferTo).balanceOf(transferTo.address)
  console.log("PanaCoin Balance for transferTo address = ", ethers.utils.formatEther(panacoinBalance));



}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
