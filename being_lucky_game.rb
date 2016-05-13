#!/usr/bin/env ruby
require 'optparse'
require 'highline'
require_relative 'lib/being_lucky'

class BeingLuckyGame
  def initialize(options)
    @game = BeingLucky.new(options)
  end

  def self.run
    options = {}

    optparse = OptionParser.new do |opts|
      opts.on('-n', '--no_players N', Integer, '[required] Number of players (min: 2, max: 9)') do |n|
        options[:no_players] = n
      end
      opts.banner = "Usage: #{opts.program_name} [options]"
    end

    if ARGV.empty?
      puts optparse
      exit
    end

    begin
      optparse.parse!
      raise 'Number of players must be between 2 and 9' if options[:no_players] < 2 || options[:no_players] > 9
    rescue => e
      puts e
      puts optparse
      exit
    end

    BeingLuckyGame.new(options).play
  end

  def play
    last_round = false

    until last_round
      @game.players.each do |player|
        unless @game.joined_game?(player)

          if prompt_yesno_question("Player ##{player} wants to join the game now?  ") == :Yes
            try_again = true

            while try_again
              joined, roll, points = @game.join_game(player)

              if joined
                puts "Cool, player ##{player} just joined the game with #{points} points! (#{roll})"
                try_again = false
              else
                try_again = false if prompt_yesno_question("Player ##{player} didn't make it (#{roll} => #{points}). Do you want to try again?  ") == :No
              end
            end
          end
        end

        next unless @game.joined_game?(player)

        keep_playing = prompt_yesno_question(
          "Player ##{player} has #{@game.player_current_points(player)} point(s) and #{@game.player_next_roll(player)} dice(s) left. Do you want to roll them?  "
        ) == :Yes

        while keep_playing
          points, roll = @game.roll_dices(player)
          total_points = @game.player_current_points(player)

          if points > 0
            puts "Great! Player ##{player} added #{points} to his points, and now has #{total_points} points. (#{roll})"
          else
            puts "Ops.. it seems player ##{player} missed this roll. And now he has #{total_points} points. (#{roll})"
          end

          if @game.player_current_points(player) >= 3000
            last_round    = true
            keep_playing  = false
          else
            if prompt_yesno_question(
              "Player ##{player} has #{@game.player_next_roll(player)} dice(s) left. Do you want to roll them?  "
            ) == :Yes
              keep_playing = true
            else
              keep_playing = false
            end
          end
        end
        @game.reset_next_roll(player)

        break if last_round
      end
    end

    play_last_round
  end

  private

  def play_last_round
    @game.players.each { |player| @game.reset_next_roll(player) }

    puts 'ATTENTION: This is the final round! Each player will have his last chance to win.'

    @game.players.each do |player|
      keep_playing = prompt_yesno_question(
        "Player ##{player} has #{@game.player_current_points(player)} point(s). Do you want to play your last round?  "
      ) == :Yes

      while keep_playing
        points, roll = @game.roll_dices(player)
        total_points = @game.player_current_points(player)

        if points > 0
          puts "Great! Player ##{player} added #{points} to his points, and now has #{total_points} points. (#{roll})"

          keep_playing = false if @game.next_roll(player) == 5

          if prompt_yesno_question(
            "Player ##{player} has #{@game.player_next_roll(player)} dice(s) left. Do you want to roll them?  "
          ) == :Yes
            keep_playing = true
          else
            keep_playing = false
          end
        else
          puts "Ops.. it seems player ##{player} missed this roll. And now he has #{total_points} points. (#{roll})"
          keep_playing = false
        end
      end
    end

    puts "Player ##{@game.winner} is the winner with #{@game.player_current_points(@game.winner)} points!"

    exit
  end

  def prompt_yesno_question(question)
    cli = HighLine.new
    cli.choose do |menu|
      menu.prompt = question
      menu.choices(:Yes, :No)
    end
  end
end

BeingLuckyGame.run if __FILE__ == $PROGRAM_NAME
