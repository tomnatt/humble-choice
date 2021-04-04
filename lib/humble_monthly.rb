require 'csv'
require 'yaml'
require_relative './game'

class HumbleMonthly
  attr_reader :output

  def initialize
    @humble_montly = 'data/humble-choice-2015-2019.csv'
    @output = {}

    read_monthly_data
  end

  def read_monthly_data
    CSV.read(@humble_montly, { headers: true }).each do |row|
      date = Date.parse(row['Month'])
      year = date.year
      month = date.strftime('%B')

      games = []
      split_game_list(row['Game'], games)
      split_game_list(row['More games'], games)

      create_game_objects(games, month, year)
    end
  end

  def split_game_list(list, games)
    list.split(';').each { |game| games.concat(clean_games_list(game)) }
  end

  def create_game_objects(games, month, year)
    @output[year] = [] unless @output[year]
    games.each do |game|
      @output[year] << Game.new(game, month, year) unless game.empty?
    end
  end

  def clean_games_list(game)
    games = []

    # Remove [ if first character
    game.delete_prefix!('[')

    if game.include?(' + ')
      game.split(' + ').each { |g| games << g.strip }
    elsif game.include?('] OR [')
      game.split('] OR [').each { |g| games << g.strip.delete_suffix(']') }
    else
      games << game.strip
    end

    games
  end
end
