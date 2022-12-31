module.exports = {
  networks: {
    development: {
      host: "192.168.29.49",
      port: 7545,
      network_id: "*", // Match any network id
      gas: 5000000
    }
  },
  advanced: {
    websockets: true, // Enable EventEmitter interface for web3 (default: false)
  },
  contracts_build_directory: "./src/abis/",
  compilers: {
    solc: {
      settings: {
        optimizer: {
          enabled: true, // Default: false
          runs: 200      // Default: 200
        },
        evmVersion: "byzantium"
      }
    }
  }
};
