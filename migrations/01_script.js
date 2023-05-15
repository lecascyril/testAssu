const AssuFactory = artifacts.require("AssuFactory");

module.exports = async (deployer) => {
  await deployer.deploy(AssuFactory);
};