import { ContractReceipt, ContractTransaction } from '@ethersproject/contracts';
import { BigNumber } from 'ethers';
import { ethers, run, network } from 'hardhat';
import { APIToken, APIToken__factory, InvestmentPools, InvestmentPools__factory, PanacloudPlatform, PanacloudPlatform__factory } from '../typechain';

const deployedAddresses = require("../deployment/addresses.json");

async function main() {

  const [owner] = await ethers.getSigners();
  const networkName = network.name; 
  console.log("Network = ",networkName);
  
  const APIToken:APIToken__factory = await ethers.getContractFactory("APIToken");
  const apiToken:APIToken = await APIToken.attach("0x94099942864EA81cCF197E9D71ac53310b1468D8");
  console.log("APIToken Address to:", apiToken.address);
  const apiTokenOwner = await apiToken.owner();
  console.log("APIToken owner:", apiTokenOwner);
  const totalSupply = (await apiToken.totalSupply()).toString();
  console.log("APIToken totalSupply:", totalSupply);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
