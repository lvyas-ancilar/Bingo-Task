# Bingo Assignment 

Bingo Rules : 
    5x5 board, middle spot is free.
    Sequence of 5 marked numbers in a row, column, or diagonal to win.

The host will be Smart Contract 
Random nunber to be drawed via prevrandao /blockhash given in assumption 
Payment using erc20 transfer token  

## Core Functionalities 

1) Support Multiplayer : 1 game instance has N players 
Each player will have its own board
Each player will pay fees in terms of erc20 token , will be transffered when you join 

2) Support Multiple concurrent game at the same time 
Each game  :    
            Has its own players 
            state must be isolated 

3) ERC20 Entry fee to join 
    Player must approve first 
    On joining: transferFrom(player → contract)

4) Total pot for each game  : Total pot = entryFee × players
Winner will win the pot 
One winner per game 

5) Timing Constraints : if game is created at time T 
Players can join only during join window
No number drawing before join window ends

joinEndTime = gameCreated + joiningWindow 

6) Time window during each draw of a number 


7) Admin Control : Admin can update Entry fee , join duration , turn duration 

8) States in bingo game 
        Not created 
        Created/Joining
        Active (Numbers coming randomly)
        Finished 


## Simple game

One bingo game : gameId 
Rules decided by admin  : Entry fee , join time , turn time , 
GAME STATE : Joining 

for now lets assume we have 2 players , players a and player b 
both players gave fees 
player a join : he gets his bingo board 
player b join : he also gets hius board 

Untill state is JOINING , more can join 
when state changed to PLAYING : None should join

Now numbers will start drawing turn by turn 
Ek nunmber draw hua , player will check in his board whether he has or he has not , then if he has than he will tickmark it or else no 
each turn will have a little time gap : like a random number generated then we wait for t time to generate the number again 

now when someone gets bingo , basicaly ek puri line banegi 
so here player will claim the bingo and the contract will verify the bingo 
if everything is fine theh 
STATE : Finsihed 
Winner : player address 

Reward system : who wins gets the whole pot 
one erc20 tranfer to the winner player address
and then STATE = FINISHED

## Required Things

-> Each game a unique id and a state 
->Timing , when and where what is allwoed and now allowed 
->Player and money : how many players have joined (list of player address mapping ) , entry fee for total pot, winner address at the end 
->Gameplay data : draw number (two ways either we create a array for it or a mapping(number drawn => bool true/false))
                  PLayer Boards : Minimum board data 5x5 = 25 , ceneter point free 

Game:
- id
- state
- joinEndTime
- lastDrawTime
- entryFee
- pot
- players[]
- boards[player]
- drawnNumbers
- winner

## Now how will player claim the win and we verify 

We need to match the board 
Line is formed via the drawn numbers 
free center cell rule is followed 
exactly 5 in a row/col/diagonal 

What should contract contain ??
Ans : Player ke board ki detail  and drawn number ki history 

What player needs to show ?
Ans :  Player can just tell which line for the bingo 
for eg , if row then which row : row 0 ,1, 2, 3 , 4
if col then which col : col 0 , 1,2 ,3 4
if diagonla then top left to bottom right or top right to bottom left 

so total 5+5+2 = 12 possble lines 

## How will contract verify ???
Given the line pattern , 
if center position is there -> auto mark 
else it will check drawn[number] == true (if we are using mapping)
if all are marked then bingo valid !!!
state changed , winner fund transfer 


## What will game data contains ?
Ans : 1) Status of room 
      2) when joining end 
      3) when was last number drawn 
      4) entry fees 
      5) how many people join the game 
      6) each players boards 
      7) numbers drawn till now 
      8) winner 
 This could be one game data for a gameId     


## Board 
Bingo board  = 5 x 5 = 25 cells 
each cell will contain a random number , but the center cell will be marked as free 
the random number will also be between 0-255 to uint8 i.e 2^8 
the board size will be of 25 bytes 


rows = m
cols = n
Total Elements  = m * n

Example : 
```
   0  1   2
0->1   3   5
1->7   9   11
```
Rows = 2
cols = 3

now flatten this 

```
Index:   0   1   2   3   4   5
Value:   1   3   5   7   9   11
```
Now if we ned to find what element is at index 4 
now in plain array at index 4 value is 9 but , how to find this in row and col way 
where this element was in which row in which col 

Formula for row and col 
```
row = index / total_columns
col = index % total_columns
```
total_columns = for this eg : 3
row  = 4/3 = 1
col = 4 % 3 = 1

so matrix[1][1] = 9;

## How will player join the game ?
Ans : check 1 -> is the game joinable (state of the game and person not in any other game)
      check 2 -> join time of the game ended or not 
      check 3 -> Player already there or not isPlayer[msg.sender] should be false  


## Taking fees from the player 
Player will approve the bingo contract to transfer money on behalf of him 
so we will use transferfrom 

so first we will approve and then transferfrom 

Player → ERC20.approve(contract, entryFee)
if we dont approve then txn fails !

Contract → ERC20.transferFrom(player, contract, entryFee)


## Block.timestamp
block.timestamp = when the block was proposed by block builder , they put the timestamp in the block header as a meta data 
Now in our bingo game we need time bases states to be changed and things which required time based activity 
for that we need reference time , so for that we use block.timestamp

Basically block.timestamp is not the actual time ..

Unix epoch is a globally agreed reference point in time : 01 January 1970, 00:00:00 UTC
Epoch time = 0
1 second later = 1
1 minute later = 60
1 hour later = 3600

block.timestamp = 1,720,000,000
This literally means : 1,720,000,000 seconds have passed since , 1 Jan 1970, 00:00:00 UTC


## block.prevrandao
prevrandao is the randomness value produced by the beacon chain RANDAO and injected into the execution layer.
block in its meta data header contains this value 

## claimBingo part , how will we verify it ??
Ans : Pull based winner claim 
Player just need to prove one winning line , thats it either row , col or diagonal 

What player will submit ??
Ans : indexes of the 5 cells that form the winning line

Bingo Board 
```
Index layout:

 0   1   2   3   4
 5   6   7   8   9
10  11  12  13  14
15  16  17  18  19
20  21  22  23  24
```

Eg : Suppose number are drawn : [7, 66, 90, 21, 4]
Correspond to these incices     [10, 11, 12, 13, 14]
This is full middle row 

Now player claims bingo 
player will send the indices like 10,11,12,13,14 
from here the contract perorms multiple checks 

isValidLine(line) sees ONLY this : [10, 11, 12, 13, 14]
It does not know
which player
which board
which numbers are drawn
which game

It just checks :
All indices are between 0–24
No duplicates
All in same row?
10 / 5 = 2
11 / 5 = 2
12 / 5 = 2
13 / 5 = 2
14 / 5 = 2
if YES then  valid

few more things we will check such as player owns the board or not 
For each index in line : board.cells[index] == drawnNumber?

ensure the numbers are drawn and it matches 
also ensure bingo is not made already 
and then we transfer the pot to winner address 

Eg : 
