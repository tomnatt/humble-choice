require 'csv'
require 'google_drive'
require 'yaml'
require_relative './game'

class HumbleMonthly
  attr_reader :output

  def initialize
    session = GoogleDrive::Session.from_service_account_key(ENV['HUMBLE_CHOICE_SERVICE_ACCOUNT_KEY'])

    # Get the sheet:
    # https://docs.google.com/spreadsheets/d/1VZHuYi0OB6kc9Ma31RG57S7GqX2ND3Gk3FFfgDkToIk/edit#gid=142401517
    @worksheet = session.spreadsheet_by_key('1VZHuYi0OB6kc9Ma31RG57S7GqX2ND3Gk3FFfgDkToIk').worksheets.first
    @output = {}

    read_monthly_data
  end

  def read_monthly_data
    # Spreadsheet in format [ Month, Game ]
    # Skip first row (contains headers)
    @worksheet.rows.drop(1).each do |row|
      date = Date.parse(row[0])
      year = date.year
      month = date.strftime('%B')

      games = []
      split_game_list(row[1], games)

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
