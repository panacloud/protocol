import { ethers, run } from 'hardhat';
import { ApiToken__factory, PanaFactory, PanaFactory__factory } from '../typechain';

async function main() {
/*
    const APITokenFactory:apitoken = await ethers.getContractFactory("APITokenFactory");
    const aPITokenFactory:A

  console.log("Median Library address: ",median.address);
    const PanaFactory:PanaFactory__factory = await ethers.getContractFactory("PanaFactory",{
        libraries: {
          Median:median.address
        }
      });
    const panaFactory:PanaFactory = await PanaFactory.deploy();
    await panaFactory.deployed();

    console.log(`PanaFactory Deployed to : ${panaFactory.address}`);
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
