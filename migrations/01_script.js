const Assu = artifacts.require("Assu");
const Secu = artifacts.require("Secu");


module.exports = async (deployer) => {
  await deployer.deploy(Secu);
  await deployer.deploy(Assu, Secu.address);
};