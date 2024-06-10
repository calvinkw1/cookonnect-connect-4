class GamesController < ApplicationController
  def new
    @game = Game.new
  end

  def show
    @game = Game.find(params[:id])
  end

  def create
    red_player = Player.create(name: game_params[:player][:red_player_name])
    black_player = Player.create(name: game_params[:player][:black_player_name])

    if red_player && black_player
      game = Game.create(red_player: red_player, black_player: black_player)
    end

    redirect_to game
  end

  def update
    game = Game.find(params[:id])
    game.drop_checker(column: move_params[:column].to_i)

    redirect_to game
  end

  private

  def game_params
    params.require(:game).permit(player: [:red_player_name, :black_player_name])
  end

  def move_params
    params.permit(:column)
  end
end
