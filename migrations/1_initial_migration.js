const BigNumber = require('bignumber.js');
let yfxContract = artifacts.require("./YFX.sol");
let factoryContract = artifacts.require("./TreasuryVesterFactory.sol");

const owner = "0x0444C019C90402033fF8246BCeA440CeB9468C88";
const emergencyRecipient = "0x0444C019C90402033fF8246BCeA440CeB9468C88";
const name = "YFX";
const symbol = "YFX";
const cap = new BigNumber(1e26);

module.exports = async function (deployer) {
    await deployer.deploy(yfxContract, owner, emergencyRecipient, name, symbol, cap);
    await deployer.deploy(factoryContract, yfxContract.address);
};
