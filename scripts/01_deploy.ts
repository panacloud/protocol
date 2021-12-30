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
  console.log("PanaCoin deployed to:", panaCoin.address);

  const APINFT:APINFT__factory = await ethers.getContractFactory("APINFT");
  const apiNFT:APINFT = await APINFT.deploy();
  await apiNFT.deployed();
  console.log("APINFT deployed to:", apiNFT.address);


  const PanacloudPlatform:PanacloudPlatform__factory = await ethers.getContractFactory("PanacloudPlatform");
  const panacloudPlatform:PanacloudPlatform = await PanacloudPlatform.deploy();
  await panacloudPlatform.deployed();
  console.log("PanacloudPlatform deployed to:", panacloudPlatform.address);
  const txt1:ContractTransaction = await panacloudPlatform.initialize(paymentSplitter.address);
  //const txt1:ContractTransaction = await panacloudPlatform.initialize("0xd88Ab12f329C3e5dBaD1092b7E4710a7C3B2731C");
  console.log("PanacloudPlatform.initialize transaction hash:", txt1.hash);
  const txtReceipt1:ContractReceipt = await txt1.wait();
  console.log("PanacloudPlatform.initialize transaction completed");


  const PanaFactory:PanaFactory__factory = await ethers.getContractFactory("PanaFactory");
  const panaFactory:PanaFactory = await PanaFactory.deploy();
  await panaFactory.deployed();
  console.log("PanaFactory deployed to:", panaFactory.address);
  const txt2:ContractTransaction = await panaFactory.initialize(panaCoin.address, apiNFT.address, panacloudPlatform.address, apiTokenFactory.address, daoFactory.address);
  //const txt2:ContractTransaction = await panaFactory.initialize("0xFda643aE677a2155795a9e3154C691d9Df18237d", "0x6825755326cF5cc3BB432b0A05060f3dA2D7eCa7", panacloudPlatform.address, "0x18630eC22859f7E7725513b1CEcCa7df2dB764B6", "0x4E9b5f6B43d5A497BB3Eb45a1474694Da1761Ac2");
  console.log("panaFactory.initialize transaction hash:", txt2.hash);
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
  //const txt3:ContractTransaction = await platformGoverner.initialize("0xC58B924Feb50C42f4F6226D50c3f53f11ACbD536","0xA6854e9Df13cCCD78Ad53EF249B2eA0Eb2E7bF6c", "0xFda643aE677a2155795a9e3154C691d9Df18237d");
  console.log("PlatformGoverner.initialize transaction hash:", txt3.hash);
  const txtReceipt3:ContractReceipt = await txt3.wait();
  console.log("PlatformGoverner.initialize transaction completed");
  

  /*
  // Not needed for now
  const PanacloudController:PanacloudController__factory = await ethers.getContractFactory("PanacloudController");
  const panacloudController:PanacloudController = await PanacloudController.deploy();
  await panacloudController.deployed();
  console.log("PanacloudController deployed to:", panacloudController.address);

  const txt4:ContractTransaction = await panacloudController.initialize(panaCoin.address,apiNFT.address,panacloudPlatform.address,platformGoverner.address,panaFactory.address,timelock.address,apiTokenFactory.address, daoFactory.address);
  console.log("PanacloudController.initialize transaction:", txt4.hash);
  const txtReceipt4:ContractReceipt = await txt4.wait();
  console.log("PanacloudController.initialize transaction completed");
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