# README

## Getting started
Pre-requisites:
- Running postgres server
- Ruby 3.1.4
- Node v16.18.0 (For Bootstrap 5.3.3)

```
1. bundle install
2. bundle exec rails db:migrate
3. bundle exec rails server
```

Start a new game at http://localhost:3000/games/new

## Design
The architecture is centered around a `Game` model. There is also a `Player` model but is only used for tying the player to red/black for the game.

### Game
The `Game` model handles 3 things:
1. Initializing the game board
2. Gameplay
3. Checking for wins

The board is initialized as a hash of hashes to represent the 6 row x 7 column grid. This is stored in `game.board`, with a `jsonb` data type, which gives some flexibility in storing the board info without committing to a relational model just yet:
```ruby
{
  "row_0"=>
  {"col_0"=>{"color"=>"red", "move_num"=>1},
   "col_1"=>{"color"=>"red", "move_num"=>13},
   "col_2"=>{"color"=>"black", "move_num"=>4},
   "col_3"=>{"color"=>"red", "move_num"=>3},
   "col_4"=>{"color"=>"red", "move_num"=>5},
   "col_5"=>{"color"=>"red", "move_num"=>9},
   "col_6"=>{"color"=>"black", "move_num"=>2}},
 "row_1"=>
  {"col_0"=>{"color"=>nil, "move_num"=>nil},
   "col_1"=>{"color"=>"red", "move_num"=>17},
   "col_2"=>{"color"=>"black", "move_num"=>14},
   "col_3"=>{"color"=>"black", "move_num"=>6},
   "col_4"=>{"color"=>"red", "move_num"=>7},
   "col_5"=>{"color"=>"red", "move_num"=>11},
   "col_6"=>{"color"=>"black", "move_num"=>10}},
 "row_2"=>
  {"col_0"=>{"color"=>nil, "move_num"=>nil},
   "col_1"=>{"color"=>nil, "move_num"=>nil},
   "col_2"=>{"color"=>"red", "move_num"=>15},
   "col_3"=>{"color"=>"black", "move_num"=>16},
   "col_4"=>{"color"=>"black", "move_num"=>8},
   "col_5"=>{"color"=>nil, "move_num"=>nil},
   "col_6"=>{"color"=>"black", "move_num"=>12}},
 "row_3"=>
  {"col_0"=>{"color"=>nil, "move_num"=>nil},
   "col_1"=>{"color"=>nil, "move_num"=>nil},
   "col_2"=>{"color"=>nil, "move_num"=>nil},
   "col_3"=>{"color"=>"black", "move_num"=>18},
   "col_4"=>{"color"=>"red", "move_num"=>19},
   "col_5"=>{"color"=>nil, "move_num"=>nil},
   "col_6"=>{"color"=>"black", "move_num"=>20}},
 "row_4"=>
  {"col_0"=>{"color"=>nil, "move_num"=>nil},
   "col_1"=>{"color"=>nil, "move_num"=>nil},
   "col_2"=>{"color"=>nil, "move_num"=>nil},
   "col_3"=>{"color"=>nil, "move_num"=>nil},
   "col_4"=>{"color"=>nil, "move_num"=>nil},
   "col_5"=>{"color"=>nil, "move_num"=>nil},
   "col_6"=>{"color"=>nil, "move_num"=>nil}},
 "row_5"=>
  {"col_0"=>{"color"=>nil, "move_num"=>nil},
   "col_1"=>{"color"=>nil, "move_num"=>nil},
   "col_2"=>{"color"=>nil, "move_num"=>nil},
   "col_3"=>{"color"=>nil, "move_num"=>nil},
   "col_4"=>{"color"=>nil, "move_num"=>nil},
   "col_5"=>{"color"=>nil, "move_num"=>nil},
   "col_6"=>{"color"=>nil, "move_num"=>nil}}
}
 ```
This was chosen over an array of arrays because of the benefits of being able to associate additional data with each cell, like the `move_num` or perhaps a `move_timestamp`. This does create a bit of complication with accessing the values of each column but I believe the minor complexity increase to be worth it in order to provide a stateful representation about the progression of the game. Examples:
- A game replay mode
- Time that a player spent considering the move

#### Gameplay
This is mostly handled by a `drop_checker` method that takes a `column` as a parameter. It determines which row the checker should land in that column, as the checkers should be stacked.

There was some initial consideration for this method to be moved to the `Player` model, but given that the `Game` only cares about colors, I decided to leave the method within the `Game` model.

There is a `status` enum that represents the given state of a game and this status is updated whenever the necessary conditions of the game are met.

```json
{
  in_progress: 0,
  red_won: 1,
  black_won: 2,
  draw: 3
}
```
Directly mapping the symbols to integers lends itself for easier interpretation of data for business units that may be looking at the data in something like Looker, where the names of the statuses aren't readily available.

#### Checking for wins
There are 4 outcomes for a Game:
- Horizontal win
  - Validate each row has at least 4 checkers and then validate 4 consecutive checkers of the same color
- Vertical win
  - Validate each column has at least 4 checkers and then validate 4 consecutive checkers of the same color
- Diagonal win
  - Split into two directional checks - Up Right and Up Left. The boundaries of the game grid dictate that only the first 4 columns and the first 3 rows can result in a diagonal up right win. The last 4 columns and first 3 rows can result in a diagonal up left win. Beyond those boundaries, there's not enough cells to get 4 consecutive checkers in those directions.
- Draw
  - Simple enough - if there's no winner, and all 42 cells have been played, the game is over and results in a draw.

The 3 win directions, horizontal/vertical/diagonal, call a single `check_consecutive_colors` method that take in colors as an array of strings using variables `current_color` and `consecutive_count`.

These methods to handle the win logic are currently in the `Game` model and ideally should be moved into a Service object or a Concern. Where they can be unit tested with various game board representations.

### Testing
There are currently no tests, but given more time, I would follow a BDD approach using `RSpec`, unit testing service objects and model methods and ensuring 100% branch converage using tools like `simplecov`.

The testing suite would be run by something like CircleCI and with a repository hosted in Github and platform hosted in Heroku, could be easily integrated into Heroku Pipelines and allow for a pretty comprehensive CI/CD pipeline where green test builds can trigger automatic deployments to a staging environment that is just building off the top of the `master/main` branch.

### Miscellaneous
- Each game move currently triggers a full page refresh. This can instead be handled by Turbo, rendering a turbo.stream.erb template that can simply update only the element that needs updating, in this case a cell.
- Presenter pattern can be used to remove logic from the view
- My initial notes on the design can be found in this file `connect_4_offline_exercise.md`