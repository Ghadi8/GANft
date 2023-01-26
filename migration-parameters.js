const Web3 = require("web3");
const provider = new Web3.providers.HttpProvider(
  "https://goerli.infura.io/v3/3e35aed6a5f34a34b79777b92e88a015"
);
var web3 = new Web3(provider);

module.exports = {
  devnet: {
    name: "GANft",
    symbol: "GA",
    uri: "ipfs:///",
    minter: "0x5A5ED9D4526146EfB6090A63f03B02DcfC603A8e",
    payees: ["0xb094d5A295F88868AA3F57511104258d494A5143"],
    shares: [1],
  },
  goerli: {
    name: "GANft",
    symbol: "GA",
    uri: "https://bafybeibgvqeedb2jxbltmlje6ximfgkxtv2mfwrl7s4kaamm7bx3higgdm.ipfs.nftstorage.link/",
    minter: "0x5A5ED9D4526146EfB6090A63f03B02DcfC603A8e",
    payees: ["0xb094d5A295F88868AA3F57511104258d494A5143"],
    shares: [1],
  },
  mumbai: {
    name: "ganft",
    symbol: "GA",
    uri: "https://bafybeibgvqeedb2jxbltmlje6ximfgkxtv2mfwrl7s4kaamm7bx3higgdm.ipfs.nftstorage.link/",
    minter: "0x5A5ED9D4526146EfB6090A63f03B02DcfC603A8e",
    payees: ["0xb094d5A295F88868AA3F57511104258d494A5143"],
    shares: [1],
  },
  mainnet: {},
};
