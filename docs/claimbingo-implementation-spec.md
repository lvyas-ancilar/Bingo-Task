# claimBingo Implementation Spec (Issue #4)

## Goal
Implement `claimBingo` validation and winner payout so that valid claims succeed once and invalid claims always fail.

## Required checks
1. Game must be in `Active` state.
2. No winner must already be set.
3. Claimed line type must be one of:
   - `row` (index 0-4)
   - `col` (index 0-4)
   - `diag-main`
   - `diag-anti`
4. Claimed cells must map to exactly 5 board slots.
5. Free center cell (`index 12`) is treated as auto-marked.
6. All non-center claimed numbers must be present in drawn numbers.

## State changes on success
- Set `winner` to claimer address.
- Set game state to `Finished`.
- Transfer full game pot to winner in same transaction.
- Emit:
  - `BingoClaimed(gameId, winner, lineType, lineIndex)`
  - `GameFinished(gameId, winner, payout)`

## Revert conditions
- Invalid game state.
- Invalid line type or index.
- Claimed line contains undrawn numbers.
- Winner already exists.
- Zero pot or failed payout transfer.

## Suggested tests
- Valid row claim succeeds and closes game.
- Valid column claim succeeds and closes game.
- Main/anti diagonal claim succeeds.
- Invalid index reverts.
- Undrawn number in line reverts.
- Second claim after winner reverts.
- Pot paid exactly once to winner.

## Notes
Keep loops bounded to fixed-size arrays only (5 or 25 max) to keep gas predictable.