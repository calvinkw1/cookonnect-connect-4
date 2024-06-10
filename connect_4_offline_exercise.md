<!-- This markdown file was exported from Notion -->

# Connect four offline exercise

## Instructions

We are going to create a web app that allows us to play connect four. Here are the [rules of connect four](https://www.unco.edu/hewit/pdf/giant-map/connect-4-instructions.pdf) if you are not familiar. The board has 6 rows and 7 columns. Checkers can be inserted at the top of the column and fall to the lowest unoccupied space in the column. Players take alternating turns inserting a checker of their color (red or black) at the top of a column. If either player connects four checkers in a row vertically, horizontally, or diagonally they win. If all spaces are filled and no one has a series of four the game is a tie.

## Scope and constraints

- Do not spend more than 60 minutes on the challenge.
- The project can be done in any web framework. Your choice.
- The implementation should include a display of the board, a way for players to take their turn, and a game result.
- You may include a writeup of your approach and any engineering tradeoffs in the implementation.

When complete please zip up the entire exercise and email it to [anndrea@alignedrecruitment.com](mailto:anndrea@alignedrecruitment.com)

### Models

- Game
    - moves_count
    - last_move_by
    - result
        - red wins, black wins, draw
    - red_player_id, black_player_id
    - board - jsonb?
        - Don’t need to commit to a new model yet
        - Hash to represent the rows/columns - initialize with each new game
            - row_1: {col_1: nil, col_2: :black, col_3: :red} (7 columns)
                - Should col_2 value also be hash? Could store move # here to represent who made the move
            - row_2: {}
            - row_3: {}
            - row_4: {}
            - row_5: {}
            - row_6: {}
    - **Helpers**
        - drop_checker(column, color)
            - move timestamp or order?
        - winner?
            - at least 1 player has made 4 moves (7 total moves)
            - horizontal_win? - check all rows with checkers
                - requires at least 4 consecutive checkers
            - vertical_win? - check all columns with checkers
                - requires at least 4 rows of checkers in the same column
            - diagonal_win? - **this needs more thought**
                - must check both left/right directions for other checkers of the same color
            - highlight_connect_four
        - draw?
            - max 42 moves
            - winner? returns false
- Player?
    - name
    - wins
    - games_played

### Board UI

- Grid - 6 rows x 7 columns
- Use turbo to update the cells?