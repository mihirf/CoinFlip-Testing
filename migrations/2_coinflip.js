const CoinFlip = artifacts.require("CoinFlip");
const Ownable = artifacts.require("Ownable");
const OracleQuery = artifacts.require("sendOracleQuery");
const Destroyable = artifacts.require("Destroyable");
module.exports = function(deployer, network, accounts) {
  deployer.deploy(CoinFlip).then(function(instance){
     instance.depositIntoContract({value: web3.utils.toWei("5", "ether"), from: accounts[0]});
  });
  deployer.deploy(Ownable);
  deployer.deploy(OracleQuery);
  deployer.deploy(Destroyable);
};
