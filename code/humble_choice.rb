require 'csv'
require 'yaml'
require './code/game'

class HumbleChoice
  attr_reader :output

  def initialize
    @humble_present = 'data/humble-choice-2019-present.csv'
    @output = {}

    read_choice_data
  end

  def read_choice_data
    CSV.read(@humble_present, { headers: true }).each do |row|
      date = Date.parse(row['Month'])
      year = date.year
      month = date.strftime('%B')

      next if year == 2019

      games = []
      split_game_list(row['Game'], games)

      create_game_objects(games, month, year)
    end
  end

  def split_game_list(list, games)
    available_games = list&.split(';')
    available_games&.each { |games_list| games.concat(clean_games_list(games_list)) }
  end

  def create_game_objects(games, month, year)
    @output[year] = [] unless @output[year]
    games.each do |game|
      @output[year] << Game.new(game, month, year) unless game.empty?
    end
    @output[year].reverse!
  end

  def clean_games_list(games_list)
    # Remove [ if first character
    games_list.delete_prefix!('[')

    # Split by the common delimeters
    games = split_on_common_delimeters(games_list)

    # Remove costs and split on commas
    remove_costs_split_on_commas(games)

    games
  end

  def split_on_common_delimeters(games_list)
    games = []

    if games_list.include?(' + ')
      games_list.split(' + ').each { |g| games << g.strip }

    elsif games_list.include?('] OR [')
      games_list.split('] OR [').each { |g| games << g.strip.delete_suffix(']') }

    else
      games << games_list.strip
    end

    games
  end

  def remove_costs_split_on_commas(games)
    games.each_with_index do |g, index|
      case g
      when / \(\$\d+\),/
        g.gsub!(/ \(\$\d+\)/, '')
        games[index] = g.split(',').map(&:strip)
        games.flatten!

      when / \(\$\d+\)/
        games[index] = g.gsub(/ \(\$\d+\)/, '')
      end
    end
  end
end
