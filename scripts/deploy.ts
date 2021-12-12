import { ContractReceipt, ContractTransaction } from '@ethersproject/contracts';
import { ethers, run } from 'hardhat';
import { APINFT, APINFT__factory, APITokenFactory, APITokenFactory__factory, DAOFactory, DAOFactory__factory, PanacloudController, PanacloudController__factory, PanacloudPlatform, PanacloudPlatform__factory, PanaCoin, PanaCoin__factory, PanaFactory, PanaFactory__factory, PaymentSplitter, PaymentSplitter__factory, PlatformGoverner, PlatformGoverner__factory, Timelock, Timelock__factory } from '../typechain';

async function main() {

  const [owner] = await ethers.getSigners();

  //#region  Factories
  const APITokenFactory:APITokenFactory__factory = await ethers.getContractFactory("APITokenFactory");
  const apiTokenFactory:APITokenFactory = await APITokenFactory.deploy();
  await apiTokenFactory.deployed();
  console.log("APITokenFactory deployed to:", apiTokenFactory.address);

  const DAOFactory:DAOFactory__factory = await ethers.getContractFactory("DAOFactory");
  const daoFactory:DAOFactory = await DAOFactory.deploy();
  await daoFactory.deployed();
  console.log("DAOFactory deployed to:", daoFactory.address);
  //#endregion 

  const PaymentSplitter:PaymentSplitter__factory = await ethers.getContractFactory("PaymentSplitter");
  const paymentSplitter:PaymentSplitter = await PaymentSplitter.deploy();
  await paymentSplitter.deployed();
  console.log("PaymentSplitter deployed to:", paymentSplitter.address);

  const PanaCoin:PanaCoin__factory = await ethers.getContractFactory("PanaCoin");
  const panaCoin:PanaCoin = await PanaCoin.deploy();
  await panaCoin.deployed();
  console.log("panaCoin deployed to:", panaCoin.address);

  const APINFT:APINFT__factory = await ethers.getContractFactory("APINFT");
  const apiNFT:APINFT = await APINFT.deploy();
  await apiNFT.deployed();
  console.log("APINFT deployed to:", apiNFT.address);

  const PanacloudPlatform:PanacloudPlatform__factory = await ethers.getContractFactory("PanacloudPlatform");
  const panacloudPlatform:PanacloudPlatform = await PanacloudPlatform.deploy();
  await panacloudPlatform.deployed();
  console.log("PanacloudPlatform deployed to:", panacloudPlatform.address);
  const txt1:ContractTransaction = await panacloudPlatform.initialize(paymentSplitter.address);
  console.log("panacloudPlatform.initialize transaction:", txt1.hash);
  const txtReceipt1:ContractReceipt = await txt1.wait();
  console.log("panacloudPlatform.initialize transaction completed");


  const PanaFactory:PanaFactory__factory = await ethers.getContractFactory("PanaFactory");
  const panaFactory:PanaFactory = await PanaFactory.deploy();
  await panaFactory.deployed();
  console.log("PanaFactory deployed to:", panaFactory.address);
  const txt2:ContractTransaction = await panaFactory.initialize(panaCoin.address, apiNFT.address, panacloudPlatform.address, apiTokenFactory.address, daoFactory.address);
  console.log("panaFactory.initialize transaction:", txt2.hash);
  const txtReceipt2:ContractReceipt = await txt2.wait();
  console.log("panaFactory.initialize transaction completed");


  const Timelock:Timelock__factory = await ethers.getContractFactory("Timelock");
  const timelock:Timelock = await Timelock.deploy(owner.address, 2 * 24 * 60 * 60); // 2 days
  await timelock.deployed();
  console.log("Timelock deployed to:", timelock.address);

  const PlatformGoverner:PlatformGoverner__factory = await ethers.getContractFactory("PlatformGoverner");
  const platformGoverner:PlatformGoverner = await PlatformGoverner.deploy();
  await platformGoverner.deployed();
  console.log("PlatformGoverner deployed to:", platformGoverner.address);
  
  const txt3:ContractTransaction = await platformGoverner.initialize(panaFactory.address,timelock.address, panaCoin.address);
  console.log("PlatformGoverner.initialize transaction:", txt3.hash);
  const txtReceipt3:ContractReceipt = await txt3.wait();
  console.log("PlatformGoverner.initialize transaction completed");
  

  const PanacloudController:PanacloudController__factory = await ethers.getContractFactory("PanacloudController");
  const panacloudController:PanacloudController = await PanacloudController.deploy();
  await panacloudController.deployed();
  console.log("PanacloudController deployed to:", panacloudController.address);

  const txt4:ContractTransaction = await panacloudController.initialize(panaCoin.address,apiNFT.address,panacloudPlatform.address,platformGoverner.address,panaFactory.address,timelock.address,apiTokenFactory.address, daoFactory.address);
  console.log("PanacloudController.initialize transaction:", txt4.hash);
  const txtReceipt4:ContractReceipt = await txt4.wait();
  console.log("PanacloudController.initialize transaction completed");

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
