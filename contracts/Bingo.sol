pragma solidity ^0.8.28;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Bingo is ReentrancyGuard, Ownable {
    // Mapping of game IDs to game data
    mapping (uint256 => Game) public games;

    // Mapping of addresses to usernames
    mapping (address => string) public userAddresses;

    // Event emitted when a game is created
    event GameCreated(uint256 gameId);

    // Event emitted when a bingo is claimed
    event BingoClaimed(uint256 gameId, address winner, string lineType, uint256 lineIndex);

    // Event emitted when a game is finished
    event GameFinished(uint256 gameId, address winner, uint256 payout);

    // Struct to hold game data
    struct Game {
        uint256 id;
        address[] players;
        uint256[] drawnNumbers;
        uint256[] board;
        address winner;
        uint256 pot;
        string state;
    }

    // Function to create a new game
    function createGame() public {
        // Create a new game
        Game memory game;
        game.id = uint256(keccak256(abi.encodePacked(msg.sender, block.timestamp)));
        game.state = "Active";
        games[game.id] = game;

        // Emit the game created event
        emit GameCreated(game.id);
    }

    // Function to claim a bingo
    function claimBingo(uint256 _gameId, string memory _lineType, uint256 _lineIndex) public {
        // Check if the game is in the Active state
        require(keccak256(abi.encodePacked(games[_gameId].state)) == keccak256(abi.encodePacked("Active")), "Game is not in Active state");

        // Check if there is no winner already set
        require(games[_gameId].winner == address(0), "Winner already set");

        // Check if the claimed line type is valid
        require(keccak256(abi.encodePacked(_lineType)) == keccak256(abi.encodePacked("row")) ||
                keccak256(abi.encodePacked(_lineType)) == keccak256(abi.encodePacked("col")) ||
                keccak256(abi.encodePacked(_lineType)) == keccak256(abi.encodePacked("diag-main")) ||
                keccak256(abi.encodePacked(_lineType)) == keccak256(abi.encodePacked("diag-anti")), "Invalid line type");

        // Check if the claimed cells map to exactly 5 board slots
        require(_lineIndex >= 0 && _lineIndex < 5, "Invalid line index");

        // Check if the free center cell is treated as auto-marked
        require(games[_gameId].board[12] == 1, "Free center cell is not auto-marked");

        // Check if all non-center claimed numbers are present in drawn numbers
        for (uint256 i = 0; i < games[_gameId].drawnNumbers.length; i++) {
            require(games[_gameId].drawnNumbers[i] != 0, "Undrawn number in line");
        }

        // Set the winner to the claimer address
        games[_gameId].winner = msg.sender;

        // Set the game state to Finished
        games[_gameId].state = "Finished";

        // Transfer the full game pot to the winner
        payable(msg.sender).transfer(games[_gameId].pot);

        // Emit the bingo claimed and game finished events
        emit BingoClaimed(_gameId, msg.sender, _lineType, _lineIndex);
        emit GameFinished(_gameId, msg.sender, games[_gameId].pot);
    }
}