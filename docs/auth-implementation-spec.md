# Auth Implementation Spec

## Goal
Implement an authentication system that allows users to sign up and log in securely.

## Required Checks
1. **Username uniqueness**: Ensure that each username is unique and cannot be taken by another user.
2. **Password hashing**: Hash user passwords to prevent them from being stored in plain text.
3. **Password verification**: Verify that the input password matches the stored password hash.
4. **User data storage**: Store user data, including usernames and password hashes, in a secure manner.

## State Changes on Success
- **Sign-up**: Create a new user with the given username and password hash.
- **Log-in**: Verify the input password and return the user's data if the password is correct.

## Revert Conditions
- **Username already taken**: Revert the sign-up transaction if the username is already taken.
- **Incorrect password**: Revert the log-in transaction if the input password does not match the stored password hash.

## Suggested Tests
- **Successful sign-up**: Test that a user can sign up with a unique username and password.
- **Successful log-in**: Test that a user can log in with the correct password.
- **Failed sign-up**: Test that a user cannot sign up with a username that is already taken.
- **Failed log-in**: Test that a user cannot log in with an incorrect password.