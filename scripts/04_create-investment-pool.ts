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

  // Localhost
  /*
  const txt1 = await investmentPools.createInvestmentPool(
    "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266","0xa16E02E87b7454126E5E10d957A927A7F5B5d2be",
    BigNumber.from((new Date()).getTime()),BigNumber.from(30).mul(24).mul(60).mul(60),BigNumber.from(100),
    10000,BigNumber.from(7000), BigNumber.from(100))
  */

  // Production
  let whitelistingStartDate = new Date("1/19/1970");
    let whitelistingEndDate = new Date("2/15/1970");
  const txt1 = await investmentPools.createInvestmentPool(
              //"0xb11846818Eda46eCa2E0481A4A4AFEBB4CAC18d5","0xa1182eBDc63a68a5355235132aF9AD7555C39c03",
              owner.address,"0x703A5f09EccBC1E02E0B1FA739A7E5A5e698340C",
              BigNumber.from((new Date()).getTime()),BigNumber.from(30).mul(24).mul(60).mul(60),BigNumber.from(100),
              10000,BigNumber.from(7000), BigNumber.from(100),
              BigNumber.from(whitelistingStartDate.getTime()), BigNumber.from(whitelistingEndDate.getTime()))
  
  console.log("investmentPools.createInvestmentPool Hash: ",txt1.hash);
  const txtReceipt = await txt1.wait();
  console.log("investmentPools transaction receipt: ",txtReceipt);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
