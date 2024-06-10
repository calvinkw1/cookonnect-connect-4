class Game < ApplicationRecord
  belongs_to :red_player, class_name: 'Player'
  belongs_to :black_player, class_name: 'Player'

  enum status: { in_progress: 0, red_won: 1, black_won: 2, draw: 3 }

  after_create :initialize_board

  # @param column [Integer]
  # @return [Boolean]
  def drop_checker(column:)
    # TODO: Error handle if a column value given is greater than 7

    color = moves_count.even? ? :red : :black

    board.each do |row_name, columns|
      col = "col_#{column}"
      next if columns[col]['color'].present?

      columns[col]['color'] = color
      current_move_count = moves_count + 1
      columns[col]['move_num'] = current_move_count
      update(moves_count: current_move_count)
      columns[col][:move_num] = moves_count
      update(last_move_by: color)

      break
    end

    winner?
  end

  # @return [Boolean]
  def winner?
    return false if moves_count < 7
    return false if draw?

    # these methods can be moved to a service CheckWinner
    # and can be unit tested there with various use cases horizontal/vertical/diagonal/no-win/draw
    # CheckWinner.call(game) is called here
    horizontal_win? || vertical_win? || diagonal_win?
  end

  # @return [Player]
  def winner
    return unless winner?

    red_won? ? red_player : black_player
  end

  def draw?
    draw! if moves_count == 42
  end

  private

  # initializes a 6x7 board represented by a hash of hashes
  def initialize_board
    board = Hash.new
    6.times do |i|
      row_name = "row_#{i}".to_sym
      board[row_name] = create_columns
    end

    self.update(board: board)
  end

  def create_columns
    row = {}
    7.times do |i|
      column_name = "col_#{i}".to_sym
      row[column_name] = {
        color: nil,
        move_num: nil
      }
    end

    row
  end

  # @return [Boolean]
  def horizontal_win?
    board.each do |row_name, columns|
      checker_colors = columns.map do |column_name, column|
        columns[column_name]['color']
      end
      next if checker_colors.compact.size < 4

      return true if check_consecutive_colors(checker_colors)
    end

    false
  end

  # @return [Boolean]
  def vertical_win?
    columns_with_checkers = []
    board['row_0'].each do |col, col_values|
      next if col_values['color'].nil?

      columns_with_checkers << col
    end

    columns_with_checkers.each do |col|
      checker_colors = []
      board.each do |row, columns|
        color = columns[col]['color']
        checker_colors << color
      end
      next if checker_colors.size < 4

      return true if check_consecutive_colors(checker_colors)
    end

    false
  end

  # @return [Boolean]
  def diagonal_win?
    diagonal_up_right || diagonal_up_left
  end

  # can only check up to the 4th col and up to row 3
  # rows = ['row_0', 'row_1', 'row_2', 'row_3']
  # @return [Boolean]
  def diagonal_up_right
    winner = false
    board.each_with_index do |(row, columns), row_i|
      break if row == 'row_4'

      columns_with_checkers = []
      columns.to_a.first(4).to_h.each do |col, col_values|
        next if col_values['color'].nil?

        columns_with_checkers << col
      end

      columns_with_checkers.each do |col_name|
        col_i = col_name.split('_').last.to_i
        column_colors = diagonal_right_column_colors(row_i, col_i)

        if check_consecutive_colors(column_colors)
          winner = true
          break
        end
      end
    end

    winner
  end

  # @param row_i [Integer]
  # @param col_i [Integer]
  # @return [Array<String>]
  def diagonal_right_column_colors(row_i, col_i)
    diagonal_column_colors = []
    row_incrementor = row_i
    col_incrementor = col_i

    until row_incrementor > 5 || col_incrementor > 6
      next_row = "row_#{row_incrementor}"
      next_col = "col_#{col_incrementor}"
      diagonal_column_colors << board[next_row][next_col]['color']

      row_incrementor += 1
      col_incrementor += 1
    end

    diagonal_column_colors
  end

  # can only check beginning from the 4th col and up to row 3
  # rows = ['row_3', 'row_4', 'row_5', 'row_6']
  # @return [Boolean]
  def diagonal_up_left
    winner = false
    board.each_with_index do |(row, columns), row_i|
      break if row == 'row_4'

      columns_with_checkers = []
      columns.to_a.last(4).to_h.each do |col, col_values|
        next if col_values['color'].nil?

        columns_with_checkers << col
      end

      columns_with_checkers.each do |col_name|
        col_i = col_name.split('_').last.to_i
        column_colors = diagonal_left_column_colors(row_i, col_i)

        if check_consecutive_colors(column_colors)
          winner = true
          break
        end
      end
    end

    winner
  end

  # @param row_i [Integer]
  # @param col_i [Integer]
  # @return [Array<String>]
  def diagonal_left_column_colors(row_i, col_i)
    diagonal_column_colors = []

    row_incrementor = row_i
    col_decrementor = col_i
    until row_incrementor > 5 || col_decrementor < 0
      next_row = "row_#{row_incrementor}"
      next_col = "col_#{col_decrementor}"
      diagonal_column_colors << board[next_row][next_col]['color']

      row_incrementor += 1
      col_decrementor -= 1
    end
    diagonal_column_colors
  end

  # @param checker_colors [Array<String>]
  # @return [Boolean]
  def check_consecutive_colors(checker_colors)
    current_color = nil
    consecutive_count = 0

    checker_colors.each do |color|
      if color.present? && color == current_color
        consecutive_count += 1
      elsif color.present? && color != current_color
        current_color = color
        consecutive_count = 1
      elsif consecutive_count < 4
        current_color = nil
        consecutive_count = 0
      end
    end

    if consecutive_count == 4
      current_color == 'red' ? red_won! : black_won!

      true
    else
      false
    end
  end

end
