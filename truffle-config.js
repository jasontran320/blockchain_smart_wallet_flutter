module.exports = {
  networks: {
    development: {
      host: "127.0.0.1", 
      port: 7545, 
      network_id: "*"
    }
  }, 
  contracts_directory: "./contracts",// THe "./" is shorthand for getting out of this directory into parent
  compilers: {
    solc: {
      version: "0.8.19",
      optimizer: {
        enabled: true, 
        runs: 200
      }
    }
  }, 
  db: {
    enabled: false
  }
}