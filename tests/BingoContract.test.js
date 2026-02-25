const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("BingoContract", function () {
    let bingoContract;
    let owner;

    beforeEach(async function () {
        [owner] = await ethers.getSigners();
        const BingoContract = await ethers.getContractFactory("BingoContract");
        bingoContract = await BingoContract.deploy();
        await bingoContract.deployed();
    });

    it("Should allow a player to join the game", async function () {
        const player = await ethers.getSigner(1);
        await bingoContract.connect(player).joinGame();
        expect(await bingoContract.players(player.address)).to.be.true;
    });

    it("Should not allow a player to join the game if they are already in the game", async function () {
        const player = await ethers.getSigner(1);
        await bingoContract.connect(player).joinGame();
        await expect(bingoContract.connect(player).joinGame()).to.be.revertedWith("Player already joined");
    });

    it("Should not allow a player to join the game if the game is full", async function () {
        const maxPlayers = await bingoContract.maxPlayers();
        for (let i = 0; i < maxPlayers; i++) {
            const player = await ethers.getSigner(i);
            await bingoContract.connect(player).joinGame();
        }
        const newPlayer = await ethers.getSigner(maxPlayers);
        await expect(bingoContract.connect(newPlayer).joinGame()).to.be.revertedWith("Game is full");
    });

    it("Should allow a player to leave the game", async function () {
        const player = await ethers.getSigner(1);
        await bingoContract.connect(player).joinGame();
        await bingoContract.connect(player).leaveGame();
        expect(await bingoContract.players(player.address)).to.be.false;
    });

    it("Should not allow a player to leave the game if they are not in the game", async function () {
        const player = await ethers.getSigner(1);
        await expect(bingoContract.connect(player).leaveGame()).to.be.revertedWith("Player not in game");
    });
});