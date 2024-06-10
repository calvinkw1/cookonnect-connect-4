# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_06_07_222112) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "games", force: :cascade do |t|
    t.integer "moves_count", default: 0
    t.string "last_move_by"
    t.integer "status", default: 0
    t.bigint "red_player_id", null: false
    t.bigint "black_player_id", null: false
    t.jsonb "board"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["black_player_id"], name: "index_games_on_black_player_id"
    t.index ["red_player_id"], name: "index_games_on_red_player_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.integer "wins"
    t.integer "games_played"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "games", "players", column: "black_player_id"
  add_foreign_key "games", "players", column: "red_player_id"
end
