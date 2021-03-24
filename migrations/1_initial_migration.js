// let YFX = artifacts.require("./YFX.sol");
//
// module.exports = async function (deployer) {
//     await deployer.deploy(YFX, '0x0444C019C90402033fF8246BCeA440CeB9468C88', '0x0444C019C90402033fF8246BCeA440CeB9468C88');
// };

//const Migrations = artifacts.require("Migrations");
const AddrPower = artifacts.require(".AddrPower");
const kokoRouter = artifacts.require("kokoRouter");
const kokoXRouter = artifacts.require("kokoXRouter");
const kokoswap = artifacts.require("kokoswap");

var mdexrouter = "0xe38623b265b5acc9f35e696381769e556ed932f9"
var mdexName = "Mdex"
var RouterName = "ROUTER_LIST"
var KOKOSWAPName = "KOKOSWAP"

module.exports = async function(deployer) {
    //deployer.deploy(Migrations);
    //0x5Ee7dcfe2754a39C5ea3D717187953ed3F498679 is set address
    //if (["development", "develop", 'soliditycoverage'].indexOf(network) >= 0) {
    await deployer.deploy(AddrPower,"0x5Ee7dcfe2754a39C5ea3D717187953ed3F498679");
    await deployer.deploy(kokoRouter,AddrPower.address);
    await deployer.deploy(kokoXRouter,mdexrouter,mdexName);
    await deployer.deploy(kokoswap,AddrPower.address);

    const ap = await AddrPower.deployed();
    const kkr =await kokoRouter.deployed();

    await ap.addManager("0x5Ee7dcfe2754a39C5ea3D717187953ed3F498679");
    await ap.addContract(RouterName,kokoRouter.address);
    await ap.addContract(KOKOSWAPName,kokoswap.address);
    await kkr.addRouterAddr(kokoXRouter.address);


    //} else {
    //    throw Error(`wrong network ${network}`)
    //}
};
