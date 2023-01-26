const ganftCont = artifacts.require("ganft");

const { loadNetworkConfig } = require("../utils/test-utils")(web3);
const conf = require("../migration-parameters.js");

module.exports = async (callback) => {
  try {
    const network = config.network;
    const ganft = await ganftCont.deployed();

    // let c = loadNetworkConfig(conf)[network]();
    let gasUsedTotal = 0;

    console.log(`Change GAnft minter address : ${conf.mumbai.minter}`);
    const tx1 = await ganft.setURI(conf.mumbai.uri);
    gasUsedTotal += tx1.receipt.cumulativeGasUsed;
    console.log("-------------------------------\n");

    console.log("Total gas used in wei: ", gasUsedTotal);

    callback();
  } catch (e) {
    callback(e);
  }
};
