var bytesutils = artifacts.require("./bytesutils.sol");

module.exports = function(deployer) {
  deployer.deploy(bytesutils);
};
