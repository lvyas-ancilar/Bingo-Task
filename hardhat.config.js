require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");

module.exports = {
    solidity: "0.8.28",
    networks: {
        hardhat: {
            chainId: 31337,
        },
    },
    etherscan: {
        apiKey: "YOUR_ETHERSCAN_API_KEY",
    },
    contracts: [
        "contracts/Bingo.sol",
    ],
};