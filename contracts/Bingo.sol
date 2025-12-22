// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import './Validator.sol';

contract Bingo{
    // for each game there will be a struct 
    // then also a mapping for mapping(gameId => gameData)

    IERC20 public entryToken;  
  //IERC20 is a type i.e  this tye of variable which is enrtyToken will point to a erc20 standard contract/token 
  //IERC20 = ERC20 ka blueprint

    constructor(address tokenAddress) {
    entryToken = IERC20(tokenAddress); // this is basically typecasting , we are typecasting into a erc20 contract 
    }


    // game state
    enum gameState{
        JOINING, 
        PLAYING,
        FINISHED
    }

    struct Board {
        uint8[25] cells;
    }

    struct Game{
        // State
        gameState state; // state of the game 

        // Timing
        uint256 joinEndTime;  // kabh band hoga
        uint256 lastDrawTime; // last draw kabh nikla tha  
        uint256 turnDuration; // gap between each draw 

        // Money
        uint256 entryFee; // entry fee for joining the game 
        uint256 pot;    // entry fee x players  = pot
        address winner; // giving the pot to winner 

        //  Players
        address[] players;
        mapping(address => bool) isPlayer;

         //  Boards
        mapping(address => Board) boards; // bord of player a or board of player b  boards[a] / boards[b]

        //  Drawn numbers
        uint256 drawCount; 
        mapping(uint8 => bool) drawn; // numbers drawn drawn[42] => true 
        uint8[] drawHistory; // so drawnHistory = [1,2,42]
    }

    mapping(uint256 => Game) games;
    uint256 public nextGameId;

    uint256 constant defaultEntryFee = 10 ether; // 10 * 10 ^18 , as 18 by default decimal for ecr20 standard 
    uint256 constant defaultJoinDuration = 5 minutes;
    uint256 constant defaultTurnDuration = 30 seconds;



    function createGame () external {

        uint256 gameId = nextGameId;
        Game storage game = games[gameId];

        game.state = gameState.JOINING;
        game.joinEndTime = block.timestamp + defaultJoinDuration;
        game.turnDuration = defaultTurnDuration;
        game.entryFee = defaultEntryFee;

        nextGameId++;
    }

    function joinGame (uint256 gameId, uint8[25] calldata board) external {
        
        Game storage game = games[gameId]; // game reference 

        require(game.state == gameState.JOINING, "game not joinable");
        require(block.timestamp <= game.joinEndTime, "joining window closed");
        require(!game.isPlayer[msg.sender], "already joined");

        game.players.push(msg.sender);
        game.isPlayer[msg.sender] = true;

        game.boards[msg.sender] = Board({ cells: board });

        require(entryToken.transferFrom(msg.sender,address(this),game.entryFee),"entry fee transfer failed");

        game.pot += game.entryFee;

        game.players.push(msg.sender);
        game.isPlayer[msg.sender] = true;


        game.boards[msg.sender] = Board({ cells: board });
    
    }

    function startGame(uint256 gameId) external {

        Game storage game = games[gameId];

        require(game.state == gameState.JOINING, "game not in joining");
        require(block.timestamp > game.joinEndTime, "join window still open");

        // so now here we change the state 
        game.state = gameState.PLAYING;

        // setting the clock for the first draw
        game.lastDrawTime = block.timestamp;

    }

    // in every turn we need to draw a random number from the range of 0 - 255 
    // also duplicate numbers are allowed  
    function drawNumber(uint256 gameId) external {

        Game storage game = games[gameId];

        require(game.state == gameState.PLAYING, "game not active");
        require(block.timestamp >= game.lastDrawTime + game.turnDuration,"turn not finished"); // this prevents spam draw
        // this makes sure ki next draw is after a particular time , which is turn duration 

        // now the main part , random number generation , for randomness source we will use prevrandao 

        uint8 number = uint8( uint256(keccak256(abi.encodePacked(
        block.prevrandao, // base randomness
        game.drawCount,   // per-draw uniqueness
        gameId            // per-game uniqueness
        ))
        ));

        //  Update state
        game.drawn[number] = true;
        game.drawHistory.push(number);
        game.drawCount++;
        game.lastDrawTime = block.timestamp;
    }

   

    // line is basically what player will give to claim bingo ,the 5 continuous cells : row,col,diagonal
    function claimBingo(uint256 gameId , uint8[5] calldata line) external {
        Game storage game = games[gameId];

        require(game.state == gameState.PLAYING , "State is not correct");
        require(game.isPlayer[msg.sender], "not a player");

        // now validate line structure 

        require(Validate.isValidLine(line), "invalid bingo line");

        // if this gets validated that means we have validated the line , now we need to validate the numbers

        Board storage board = game.boards[msg.sender]; // the board from the player , which we already had when he join the game

        // Verifying the number drawn and the users number he claims , are they equal
        for(uint256 i = 0 ; i < 5 ; i++){
            
            uint8 idx = line[i];
            if (idx == 12) continue;

            uint8 number = board.cells[idx];
            require(game.drawn[number], "number not drawn");

        }

        game.state = gameState.FINISHED;
        game.winner = msg.sender;

        require(entryToken.transfer(game.winner, game.pot) , "transfer filed");


    }
    
}




