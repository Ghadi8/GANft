const gaNftContract = artifacts.require("GANft");

const { setEnvValue } = require("../utils/env-man");

const conf = require("../migration-parameters");

const setGANft = (n, v) => {
  setEnvValue("../", `GANft_ADDRESS${n.toUpperCase()}`, v);
};

module.exports = async (deployer, network, accounts) => {
  switch (network) {
    case "goerli":
      c = { ...conf.goerli };
      break;
    case "mainnet":
      c = { ...conf.mainnet };
      break;
    case "development":
    default:
      c = { ...conf.devnet };
  }

  // deploy GANft
  await deployer.deploy(
    gaNftContract,
    c.name,
    c.symbol,
    c.uri,
    c.maxId,
    c.mintCostPerTokenId
  );

  const gaNft = await gaNftContract.deployed();

  if (gaNft) {
    console.log(
      `Deployed: GANft
       network: ${network}
       address: ${gaNft.address}
       creator: ${accounts[0]}
    `
    );
    setGANft(network, gaNft.address);
  } else {
    console.log("GANft Deployment UNSUCCESSFUL");
  }
};
