let yfxContract = artifacts.require("./YFX.sol");
let factoryContract = artifacts.require("./TreasuryVesterFactory.sol");

const owner = "";
const emergencyRecipient = "";
const name = "YFX";
const symbol = "YFX";
const cap = 100000000e18;

module.exports = async function (deployer) {
    await deployer.deploy(yfxContract, owner, emergencyRecipient, name, symbol, cap);
    await deployer.deploy(factoryContract, yfxContract.address);
};