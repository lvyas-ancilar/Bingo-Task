const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("Bingo Contract", function () {
  let bingo;
  let token;
  let owner, player1, player2;

  const Entry_Fee = ethers.parseEther("10");

  beforeEach(async function () {
    [owner, player1, player2] = await ethers.getSigners();

    // Deployed ERC20 token
    const BingoToken = await ethers.getContractFactory("BingoToken");
    token = await BingoToken.deploy();
    await token.waitForDeployment();

    // Mint tokens to players 
    await token.mint(player1.address, ethers.parseEther("100"));
    await token.mint(player2.address, ethers.parseEther("100"));

    // Deployed Bingo contract
    const Bingo = await ethers.getContractFactory("Bingo");
    bingo = await Bingo.deploy(await token.getAddress());
    await bingo.waitForDeployment();
  });

  it("ERC20 Token contract address which we are taking as entryfee token", async function () {
  expect(await bingo.entryToken()).to.equal(await token.getAddress());
  });

  it("should create a new game with gameId equal to 0", async function () {
    await bingo.createGame();
    expect(await bingo.nextGameId()).to.equal(1);
  });

  const board = [];
  for (let i = 0; i < 25; i++) {
  board.push(i);
  }

  console.log(board);

 it("player should be able to join the game and pay the entry fee", async function () {
  await bingo.createGame();

  await token.connect(player1).approve( // basically erc20Token.approve
    await bingo.getAddress(),
    Entry_Fee
  );

  await bingo.connect(player1).joinGame(0, board); // player gave its board

  // now we need to check , did we get the entry fee or not 
  const contractBalance = await token.balanceOf(await bingo.getAddress());


  expect(contractBalance).to.equal(Entry_Fee);
 });

 
 it("should start the game when joining window is closed", async function () {
  // Create the game
  await bingo.createGame();

  // Move blockchain time forward (join duration = 5 minutes)
  await ethers.provider.send("evm_increaseTime", [5 * 60 + 1]); // evm_increaseTime means clock ko aage badhana 
  await ethers.provider.send("evm_mine"); // create a new block 

  // Call startGame
  await bingo.startGame(0);

  // Indirect verification:
  // If game is started, drawNumber should NOT revert with "game not active"
  await ethers.provider.send("evm_increaseTime", [30]);
  await ethers.provider.send("evm_mine");

  await expect(bingo.drawNumber(0)).to.not.be.reverted;
});

it("should allow drawing a number after turn duration", async function () {
  //  Create game
  await bingo.createGame();

  //  Fast-forward time to close join window
  await ethers.provider.send("evm_increaseTime", [5 * 60 + 1]);
  await ethers.provider.send("evm_mine");

  //  Start the game
  await bingo.startGame(0);

  //  Fast-forward the time to satisfy turnDuration which is 30 seconds
  await ethers.provider.send("evm_increaseTime", [30 + 1]);
  await ethers.provider.send("evm_mine");

  //  Call the drawNumber function
  await expect(bingo.drawNumber(0)).to.not.be.reverted;
  
});

it("player should be able to claim bingo", async function () {

  // Hardcoding the board 
  const board = Array(25).fill(10);

  // Create game
  await bingo.createGame();

  // Player joins the game
  await token.connect(player1).approve(
    await bingo.getAddress(),
    Entry_Fee
  );
  await bingo.connect(player1).joinGame(0, board);

  // Close joining window
  await ethers.provider.send("evm_increaseTime", [5 * 60 + 1]);
  await ethers.provider.send("evm_mine");

  //  Start game
  await bingo.startGame(0);

  //  Draw numbers multiple times
  for (let i = 0; i < 500; i++) {
    await ethers.provider.send("evm_increaseTime", [31]);
    await ethers.provider.send("evm_mine");
    await bingo.drawNumber(0);
  }

  //  Claim bingo
  const winningLine = [0, 1, 2, 3, 4];

  await expect(
    bingo.connect(player1).claimBingo(0, winningLine)
  ).to.not.be.reverted;
});



});



