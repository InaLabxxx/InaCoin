const InaCoin = artifacts.require('./InaCoin.sol')

module.exports = (deployer) => {
  let initialSupply = 100000000e18
  deployer.deploy(InaCoin, initialSupply, {
      gas: 2000000
  })
}