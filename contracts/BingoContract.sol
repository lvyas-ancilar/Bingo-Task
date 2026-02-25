pragma solidity ^0.8.0;

contract BingoContract {
    address public owner;
    mapping(address => bool) public players;
    uint256 public gameId;
    uint256 public maxPlayers;
    uint256 public currentPlayerCount;

    constructor() {
        owner = msg.sender;
        maxPlayers = 10;
        currentPlayerCount = 0;
    }

    function joinGame() public {
        require(!players[msg.sender], "Player already joined");
        require(currentPlayerCount < maxPlayers, "Game is full");
        players[msg.sender] = true;
        currentPlayerCount++;
    }

    function leaveGame() public {
        require(players[msg.sender], "Player not in game");
        players[msg.sender] = false;
        currentPlayerCount--;
    }

    function getGameId() public view returns (uint256) {
        return gameId;
    }

    function getMaxPlayers() public view returns (uint256) {
        return maxPlayers;
    }

    function getCurrentPlayerCount() public view returns (uint256) {
        return currentPlayerCount;
    }
}