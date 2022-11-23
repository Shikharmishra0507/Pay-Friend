const TransactionList = artifacts.require("TransactionList");

module.exports = function (deployer) {
deployer.deploy(TransactionList);
};
