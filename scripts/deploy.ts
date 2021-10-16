// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers, run } from 'hardhat';

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy

  const APIIdeaNFT = await ethers.getContractFactory("APIIdeaNFT");
  const aPIIdeaNFT = await APIIdeaNFT.deploy();

  await aPIIdeaNFT.deployed();

  console.log("APIIdeaNFT deployed to:", aPIIdeaNFT.address);

  const [_, addr1] = await ethers.getSigners()
  const shares = [50]
  const owner = _.address
  //console.log(_.address)

  const ApiToken = await ethers.getContractFactory("ApiToken");
  const apiToken = await ApiToken.deploy([owner], shares);

  await apiToken.deployed();

  console.log("apitoken deployed to:", apiToken.address);


  const GovernerCore = await ethers.getContractFactory("GovernerCore");
  const governerCore = await GovernerCore.deploy();

  await governerCore.deployed();

  console.log("GovernerCore deployed to:", governerCore.address);


  const PanacloudController = await ethers.getContractFactory("PanacloudController");
  const panacloudController = await PanacloudController.deploy();

  await panacloudController.deployed();

  console.log("PanacloudController deployed to:", panacloudController.address);

  const PanaCoin = await ethers.getContractFactory("PanaCoin");
  const panaCoin = await PanaCoin.deploy();

  await panaCoin.deployed();

  console.log("PanaCoin deployed to:", panaCoin.address);

  const PanaFactory = await ethers.getContractFactory("PanaFactory");
  const panaFactory = await PanaFactory.deploy();

  await panaFactory.deployed();

  console.log("PanaFactory deployed to:", panaFactory.address);

  const PlatformGoverner = await ethers.getContractFactory("PlatformGoverner");
  const platformGoverner = await PlatformGoverner.deploy();

  await platformGoverner.deployed();

  console.log("PlatformGoverner deployed to:", platformGoverner.address);


  const Timelock = await ethers.getContractFactory("Timelock");
  const timelock = await Timelock.deploy(_.address, 10);

  await timelock.deployed();

  console.log("Timelock deployed to:", timelock.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
