const { ethers } = require("hardhat");

async function deployBingoContract() {
    const BingoContract = await ethers.getContractFactory("BingoContract");
    const bingoContract = await BingoContract.deploy();
    await bingoContract.deployed();
    console.log("BingoContract deployed to:", bingoContract.address);
}

module.exports = deployBingoContract;