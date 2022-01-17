import { BigNumber } from '@ethersproject/bignumber';
import { ContractReceipt, ContractTransaction } from '@ethersproject/contracts';
import { ethers, run, network, hardhatArguments } from 'hardhat';
import hardhatConfig from '../hardhat.config';
import { PanaFactory, PanaFactory__factory } from '../typechain';
const deployedAddresses = require("../deployment/addresses.json");

async function main() {

  const [owner] = await ethers.getSigners();
  const networkName = network.name; 
  console.log("Network = ",networkName);
  const PanaFactory:PanaFactory__factory = await ethers.getContractFactory("PanaFactory");
  const panaFactory:PanaFactory = await PanaFactory.attach(deployedAddresses[networkName].panaFactory);
  console.log("PanaFactory Address to:", panaFactory.address);

  const apiDAOConfig = {
    apiProposalId: "NAN",
    apiId: "demo-api",
    //apiTitle;
    //apiType;
    daoName: "Demo DAO",
    proposalThresholdPercent: BigNumber.from(10000),
    quorumVotesPercent: BigNumber.from(40000),
    votingPeriod: BigNumber.from(24).mul(60).mul(60).div(15)
  };

  const apiTokenConfig = {
    apiTokenName: "Demo API v1",
    apiTokenSymbol: "DEMO",
    maxApiTokenSupply: BigNumber.from("1000000"), // API Token itself will apply 18 decmial places
    initialApiTokenSupply: BigNumber.from("100000"),
    developerSharePercentage: BigNumber.from("80"),
    apiInvestorSharePercentage: BigNumber.from("10"),
    thresholdForSubscriberMinting: BigNumber.from("10") // Still needs to see what it will do
  }

  const txt2:ContractTransaction = await panaFactory.createAPIDao(apiTokenConfig, apiDAOConfig);
  console.log("panaFactory.initialize transaction hash:", txt2.hash);
  const txtReceipt2:ContractReceipt = await txt2.wait();
  console.log("panaFactory.initialize transaction completed");


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
