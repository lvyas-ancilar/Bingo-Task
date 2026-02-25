const { ethers } = require("hardhat");

describe("Bingo", function () {
    let bingo;

    beforeEach(async function () {
        const Bingo = await ethers.getContractFactory("Bingo");
        bingo = await Bingo.deploy();
        await bingo.deployed();
    });

    it("Should create a new game", async function () {
        await bingo.createGame();
        const gameId = await bingo.games(0);
        expect(gameId.id).to.be.above(0);
    });

    it("Should claim a bingo", async function () {
        await bingo.createGame();
        const gameId = await bingo.games(0);
        await bingo.claimBingo(gameId.id, "row", 0);
        const winner = await bingo.games(gameId.id);
        expect(winner.winner).to.be.equal(bingo.address);
    });

    it("Should revert if game is not in Active state", async function () {
        await bingo.createGame();
        const gameId = await bingo.games(0);
        await bingo.games(gameId.id).state = "Finished";
        await expect(bingo.claimBingo(gameId.id, "row", 0)).to.be.revertedWith("Game is not in Active state");
    });

    it("Should revert if winner already set", async function () {
        await bingo.createGame();
        const gameId = await bingo.games(0);
        await bingo.games(gameId.id).winner = bingo.address;
        await expect(bingo.claimBingo(gameId.id, "row", 0)).to.be.revertedWith("Winner already set");
    });

    it("Should revert if invalid line type", async function () {
        await bingo.createGame();
        const gameId = await bingo.games(0);
        await expect(bingo.claimBingo(gameId.id, "invalid", 0)).to.be.revertedWith("Invalid line type");
    });

    it("Should revert if invalid line index", async function () {
        await bingo.createGame();
        const gameId = await bingo.games(0);
        await expect(bingo.claimBingo(gameId.id, "row", 5)).to.be.revertedWith("Invalid line index");
    });

    it("Should revert if undrawn number in line", async function () {
        await bingo.createGame();
        const gameId = await bingo.games(0);
        await bingo.games(gameId.id).drawnNumbers.push(0);
        await expect(bingo.claimBingo(gameId.id, "row", 0)).to.be.revertedWith("Undrawn number in line");
    });
});