const Web3 = require("web3");
const provider = new Web3.providers.HttpProvider("http://localhost:8545");
var web3 = new Web3(provider);

const { toTokens } = require("./utils/test-utils")(web3);

module.exports = {
  devnet: {
    name: "GANft",
    symbol: "GA",
    uri: "ipfs:///",
    maxId: 4,
    mintCostPerTokenId: [
      toTokens("0"),
      toTokens("0"),
      toTokens("0"),
      toTokens("0"),
      toTokens("0"),
    ],
  },
  goerli: {
    name: "GANft",
    symbol: "GA",
    uri: "ipfs:///",
    maxId: 4,
    mintCostPerTokenId: [
      toTokens("0"),
      toTokens("0"),
      toTokens("0"),
      toTokens("0"),
      toTokens("0"),
    ],
  },
  mainnet: {},
};
