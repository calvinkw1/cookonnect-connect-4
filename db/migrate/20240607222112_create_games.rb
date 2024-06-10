class CreateGames < ActiveRecord::Migration[7.1]
  def change
    create_table :games do |t|
      t.integer :moves_count, default: 0
      t.string :last_move_by
      t.integer :status, default: 0
      t.references :red_player, null: false, foreign_key: { to_table: :players }
      t.references :black_player, null: false, foreign_key: { to_table: :players }
      t.jsonb :board

      t.timestamps
    end
  end
end
