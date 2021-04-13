let yfxContract = artifacts.require("./YFX.sol");
let owner = "";

module.exports = async function (deployer) {
    await deployer.deploy(yfxContract);
    let yfx = await yfxContract.deployed();
    await yfx.transferOwnership(owner);
};

/*

let create2Contract = artifacts.require("./Create2Deployer.sol");
let owner = "";

module.exports = async function (deployer) {
    await deployer.deploy(create2Contract);
    let create2 = await create2Contract.deployed();
    await create2.deployYFX(owner);
};

*/

/*

let factoryContract = artifacts.require("./TreasuryVesterFactory.sol");

let yfxAddress = "";
module.exports = async function (deployer) {
    await deployer.deploy(factoryContract, yfxAddress);
};

*/