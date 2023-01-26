const gaNftContract = artifacts.require("ganft");

const { setEnvValue } = require("../utils/env-man");

const conf = require("../migration-parameters");

const setGANft = (n, v) => {
  setEnvValue("../", `ganft_ADDRESS${n.toUpperCase()}`, v);
};

module.exports = async (deployer, network, accounts) => {
  switch (network) {
    case "goerli":
      c = { ...conf.goerli };
      break;
    case "mainnet":
      c = { ...conf.mainnet };
      break;
    case "mumbai":
      c = { ...conf.mumbai };
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
    c.minter,
    c.payees,
    c.shares
  );

  const gaNft = await gaNftContract.deployed();

  if (gaNft) {
    console.log(
      `Deployed: ganft
       network: ${network}
       address: ${gaNft.address}
       creator: ${accounts[0]}
    `
    );
    setGANft(network, gaNft.address);
  } else {
    console.log("ganft Deployment UNSUCCESSFUL");
  }
};
