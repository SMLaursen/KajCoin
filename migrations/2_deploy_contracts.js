const KajCoin = artifacts.require("KajCoin");

module.exports = function(deployer) {
  deployer.deploy(KajCoin);
};
