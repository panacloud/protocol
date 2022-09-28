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

  const totalSupply = await apiToken.totalSupply();
  console.log("API Token - Total Supply = ",totalSupply.toString());
  console.log("API Token - Total Supply = ",ethers.utils.formatEther(totalSupply));
  console.log("API Token - Max Supply = ", (await apiToken._maxSupply()).toString());
  console.log("API Token - Max Supply = ", ethers.utils.formatEther(await apiToken._maxSupply()));

  const apiTokenBalanceInvestmentPool = await apiToken.balanceOf(investmentPools.address)
  console.log("API Token Balance in InvestmentPools = ", ethers.utils.formatEther(apiTokenBalanceInvestmentPool));

  const apiTokenBalanceInvestor = await apiToken.balanceOf(investor.address)
  console.log("API Token Balance in Investor's account = ", ethers.utils.formatEther(apiTokenBalanceInvestor));

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
