require_relative 'dice'

class BeingLucky
  BeingLuckyPlayer = Struct.new(:player_id, :joined_game, :points, :next_roll)

  def initialize(options)
    validate_init_options!(options)

    @players = []

    options[:no_players].times { |i| @players << BeingLuckyPlayer.new(i + 1, false, 0, 5) }
  end

  def players
    @players.collect(&:player_id)
  end

  def joined_game?(player_id)
    player = find_player!(player_id)

    player.joined_game
  end

  def player_next_roll(player_id)
    player = find_player!(player_id)

    player.next_roll
  end

  def player_current_points(player_id)
    player = find_player!(player_id)

    player.points
  end

  def join_game(player_id)
    player = find_player!(player_id)

    raise 'Player already joined the game' if player.joined_game

    player_roll = Dice.roll(player.next_roll)
    points, remaining_roll = BeingLucky.calculate_roll_points(player_roll)

    if points >= 300
      player.joined_game = true
      player.points      = points
      player.next_roll   = !remaining_roll.empty? ? remaining_roll.length : 5
    end

    [player.joined_game, player_roll, points]
  end

  def roll_dices(player_id)
    player = find_player!(player_id)

    raise 'Player not joined the game' unless joined_game?(player_id)

    player_roll = Dice.roll(player.next_roll)

    points, remaining_roll = BeingLucky.calculate_roll_points(player_roll)

    if points > 0
      player.points     += points
      player.next_roll   = remaining_roll.empty? ? 5 : remaining_roll.length
    else
      player.points    = 0
      player.next_roll = 5
    end

    [points, player_roll]
  end

  def reset_next_roll(player_id)
    player = find_player!(player_id)

    player.next_roll = 5

    true
  end

  def winner
    @players.sort { |a, b| a.points <=> b.points }.last.player_id
  end

  def self.calculate_roll_points(roll)
    validate_roll!(roll)

    total = 0

    total, remaining_roll = three_of_a_kind(roll)

    remaining_roll.delete_if do |dice|
      case dice
      when 1
        total += 100
        true
      when 5
        total += 50
        true
      else
        false
      end
    end

    [total, remaining_roll]
  end

  def self.validate_roll!(roll)
    raise 'roll parameter must be an Array' unless roll.is_a?(Array)
    raise 'roll Array can\'t be empty' if roll.empty?
    raise 'roll Array size must be between 1 and 5' if roll.length > 5
    roll.each { |n| raise 'invalid roll value' unless n.is_a?(Integer) && (1..6) === n }
  end
  private_class_method :validate_roll!

  def self.three_of_a_kind(roll)
    result_point = 0
    result_roll  = roll.clone

    dice_face = roll.select { |row| roll.count(row) > 2 }.uniq
    unless dice_face.empty?
      result_point = case dice_face.first
                     when 1 then 1000
                     when 6 then 600
                     when 5 then 500
                     when 4 then 400
                     when 3 then 300
                     when 2 then 200
                     end

      3.times { result_roll.delete_at(result_roll.index(dice_face.first)) }
    end

    [result_point, result_roll]
  end
  private_class_method :three_of_a_kind

  private

  def validate_init_options!(options)
    raise 'options is not a valid Hash object' unless options.is_a?(Hash)
    raise 'options has invalid entries' unless (options.keys - [:no_players]).empty?
    raise 'no_players must be an integer between 2 and 9' unless options[:no_players].is_a?(Integer) && options[:no_players].between?(2, 9)
  end

  def find_player!(player_id)
    raise 'Invalid player id' unless player_id.is_a?(Integer)

    player_idx = @players.index { |p| p.player_id == player_id }

    if player_idx
      @players[player_idx]
    else
      raise 'Player not found'
    end
  end
end
