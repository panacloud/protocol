import { task } from "hardhat/config";
import "@nomiclabs/hardhat-waffle";
import '@typechain/hardhat'
import '@nomiclabs/hardhat-ethers'

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more
const ALCHEMY_API_KEY = `f9Ve8ws0_LMHLdew7lncSD1f0DreXFA3`
const privateKey = `73b69d165f4513a5fde731e50e8e9c299f2f4df86f0bcab4bd4a955b151faa76`
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
export default {
  solidity: "0.8.4",
  networks: {
    ropsten: {
      url: `https://eth-ropsten.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
      accounts: [`0x${privateKey}`],
    },
    hardhat: {
      forking: {
        url: "https://eth-ropsten.alchemyapi.io/v2/f9Ve8ws0_LMHLdew7lncSD1f0DreXFA3",
      }
    }
  }
};
