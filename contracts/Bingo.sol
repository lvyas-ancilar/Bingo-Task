// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


contract Bingo{
    // for each game there will be a struct 
    // then also a mapping for mapping(gameId => gameData)

    

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

        // 4. Players
        address[] players;
        mapping(address => bool) isPlayer;

         // 5. Boards
        mapping(address => Board) boards; // bord of player a or board of player b  boards[a] / boards[b]

        // 6. Drawn numbers
        mapping(uint8 => bool) drawn; // numbers drawn drawn[42] => true 
        uint8[] drawHistory; // so drawnHistory = [1,2,42]
    }

    mapping(uint256 => Game) games;
    uint256 public nextGameId;

    uint256 constant defaultJoinDuration = 10;
    uint256 constant defaultTurnDuration = 1;
    uint256 constant defaultEntryFee = 100;


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
        
        Game storage game = games[gameId];

        require(game.state == gameState.JOINING, "game not joinable");
        require(block.timestamp <= game.joinEndTime, "join window closed");
        require(!game.isPlayer[msg.sender], "already joined");

        game.players.push(msg.sender);
        game.isPlayer[msg.sender] = true;

        game.boards[msg.sender] = Board({ cells: board });


    }


    
}




