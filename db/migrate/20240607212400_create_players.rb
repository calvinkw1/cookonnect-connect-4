class CreatePlayers < ActiveRecord::Migration[7.1]
  def change
    create_table :players do |t|
      t.string :name
      t.integer :wins
      t.integer :games_played

      t.timestamps
    end
  end
end
