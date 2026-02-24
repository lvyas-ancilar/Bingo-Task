pragma solidity ^0.8.28;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Auth is ReentrancyGuard, Ownable {
    // Mapping of usernames to user data
    mapping (string => UserData) public users;

    // Mapping of addresses to usernames
    mapping (address => string) public userAddresses;

    // Event emitted when a user signs up
    event SignUp(string username, address userAddress);

    // Event emitted when a user logs in
    event LogIn(string username, address userAddress);

    // Event emitted when a sign-up or log-in attempt fails
    event AuthenticationFailed(string message);

    // Struct to hold user data
    struct UserData {
        string username;
        string password;
        address userAddress;
    }

    // Function to sign up a new user
    function signUp(string memory _username, string memory _password) public {
        // Check if the username is already taken
        require(bytes(users[_username].username).length == 0, "Username already taken");

        // Hash the password
        string memory hashedPassword = Strings.toHexString(uint256(keccak256(abi.encodePacked(_password))));

        // Create a new user
        users[_username] = UserData(_username, hashedPassword, msg.sender);

        // Map the user's address to their username
        userAddresses[msg.sender] = _username;

        // Emit the sign-up event
        emit SignUp(_username, msg.sender);
    }

    // Function to log in an existing user
    function logIn(string memory _username, string memory _password) public {
        // Check if the username exists
        require(bytes(users[_username].username).length != 0, "Username does not exist");

        // Hash the input password
        string memory hashedPassword = Strings.toHexString(uint256(keccak256(abi.encodePacked(_password))));

        // Check if the input password matches the stored password
        require(keccak256(abi.encodePacked(users[_username].password)) == keccak256(abi.encodePacked(hashedPassword)), "Incorrect password");

        // Emit the log-in event
        emit LogIn(_username, msg.sender);
    }

    // Function to get the username of the user at a given address
    function getUsername(address _userAddress) public view returns (string memory) {
        return userAddresses[_userAddress];
    }
}