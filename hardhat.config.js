require("@nomiclabs/hardhat-etherscan");
module.exports = {
    networks: {
        mainnet: {
            mainnet: {
                provider: function () {
                    return new HDWalletProvider(privateKey, 'https://mainnet.infura.io/v3/f62c97f0c1824e4099d90856e551b798')
                },
                network_id: '1',
                gas: 8000000,
                gasPrice: 10000000000,
            },
            kovan: {
                provider: () => new HDWalletProvider(privateKey, 'https://kovan.infura.io/v3/d00f3846a5dc4e1991ad35cda94d9f62'),
                network_id: 42,       // Ropsten's id
                gas: 8000000,        // Ropsten has a lower block limit than mainnet
                gasPrice: 10000000000,
                // confirmations: 2,    // # of confs to wait between deployments. (default: 0)
                // timeoutBlocks: 500,  // # of blocks before a deployment times out  (minimum/default: 50)
                skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
            }
        }
    },
    etherscan: {
        // Your API key for Etherscan
        // Obtain one at https://etherscan.io/
        apiKey: "FD5UCJ1251Q7Q3XCC4KSJZT1TSMJDBWUMQ"
    }
};
