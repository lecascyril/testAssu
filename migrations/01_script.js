const Assu = artifacts.require("Assu");
const Secu = artifacts.require("Secu");


module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(Secu);
  const instanceSecu = await Secu.deployed();

  await deployer.deploy(Assu, Secu.address);
  const instanceAssu = await Assu.deployed();

  //await instanceSecu.set(10, {from: accounts[0]});
  await instanceSecu.addSecuTreasury({from: accounts[0], value:100000000000000000});
  await instanceAssu.depositTreasury({from: accounts[0], value:100000000000000000});

  await instanceSecu.updatePro("0x778E8b1b443824B6aB3571ceF43A807f600DA6B5", true, {from: accounts[0]});
  await instanceSecu.updateAssureur(Assu.address, true, {from: accounts[0]});
  await instanceSecu.modifySecuPolicies(1,[50,50],{from: accounts[0]});
  await instanceSecu.modifySecuPolicies(2,[100,20],{from: accounts[0]});

  await instanceAssu.createNewPolicyContract([1,2],[20,100],[1,2,5],{from: accounts[0]});

  await instanceSecu.reimburseUser(90,1,1,{from: accounts[0]});
  // let balance = await web3.eth.getBalance(accounts[0]);
  // console.log("secu balance: " + web3.utils.fromWei(balance, "ether") +" ETH");

};
