# Wordlex - brute force Wordle solver

Run this at: https://replit.com/@nshafer/wordlex

Find a list of possible solutions given the current state of the game. Input what you currently
see in the game, and it will give you the answer or a list of possible solutions if there isn't
enough info yet to come to a solution.

NOTE: This does not just find the answer based on the hash of today's date.

## Inputs

### Gray letters

The letters already tried that returned a gray color.

### Yellow letters

The letters that turned yellow.

### Green letters

The letters that have turned green, and their position.
