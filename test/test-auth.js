const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Auth Contract", function () {
    let auth;
    let owner;

    beforeEach(async function () {
        [owner] = await ethers.getSigners();

        // Deploy the Auth contract
        const Auth = await ethers.getContractFactory("Auth");
        auth = await Auth.deploy();
        await auth.deployed();
    });

    it("Should sign up a new user", async function () {
        const username = "testUser";
        const password = "testPassword";

        // Sign up the user
        await auth.signUp(username, password);

        // Check if the user was signed up successfully
        expect(await auth.getUsername(owner.address)).to.equal(username);
    });

    it("Should log in an existing user", async function () {
        const username = "testUser";
        const password = "testPassword";

        // Sign up the user
        await auth.signUp(username, password);

        // Log in the user
        await auth.logIn(username, password);

        // Check if the user was logged in successfully
        expect(await auth.getUsername(owner.address)).to.equal(username);
    });

    it("Should fail to sign up with an existing username", async function () {
        const username = "testUser";
        const password = "testPassword";

        // Sign up the user
        await auth.signUp(username, password);

        // Try to sign up with the same username
        await expect(auth.signUp(username, password)).to.be.revertedWith("Username already taken");
    });

    it("Should fail to log in with an incorrect password", async function () {
        const username = "testUser";
        const password = "testPassword";

        // Sign up the user
        await auth.signUp(username, password);

        // Try to log in with an incorrect password
        await expect(auth.logIn(username, "wrongPassword")).to.be.revertedWith("Incorrect password");
    });
});