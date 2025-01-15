require 'csv'
require 'google_drive'
require 'yaml'
require_relative 'game'

class GoogleData
  attr_reader :games_list

  def initialize
    # Get the sheet:
    # https://docs.google.com/spreadsheets/d/1VZHuYi0OB6kc9Ma31RG57S7GqX2ND3Gk3FFfgDkToIk/edit#gid=142401517
    session = GoogleDrive::Session.from_service_account_key(ENV.fetch('HUMBLE_CHOICE_SERVICE_ACCOUNT_KEY'))
    @spreadsheet = session.spreadsheet_by_key('1VZHuYi0OB6kc9Ma31RG57S7GqX2ND3Gk3FFfgDkToIk')

    monthly = read_data(@spreadsheet.worksheets.first, 'monthly')
    choice = read_data(@spreadsheet.worksheets.last, 'choice')
    # Merge Monthly and Choice lists, flatten into a single array and sort by year / month / name
    @games_list = (monthly + choice).flatten.sort_by { |g| [g.year, Date::MONTHNAMES.index(g.month), g.name] }
  end

  def read_data(worksheet, source)
    # Spreadsheet in format [ Month, Game ]
    # Skip first row (contains headers)
    games = []
    worksheet.rows.drop(1).each do |row|
      date = Date.parse(row[0])
      year = date.year
      month = date.strftime('%B')

      game_names = split_game_list(row[1])
      games << create_game_objects(game_names, month, year, source)
    end
    games
  end

  def split_game_list(list)
    games = []
    available_games = list&.split(';')
    available_games&.each { |game_name| games.concat(clean_game_name(game_name)) }
    games
  end

  def clean_game_name(game_name)
    games = []

    # Remove [ if first character
    game_name.delete_prefix!('[')

    if game_name.include?(' + ')
      game_name.split(' + ').each { |g| games << g.strip }
    elsif game_name.include?('] OR [')
      game_name.split('] OR [').each { |g| games << g.strip.delete_suffix(']') }
    else
      games << game_name.strip
    end

    games
  end

  def create_game_objects(game_names, month, year, scheme)
    games = []
    game_names.each do |game|
      games << Game.new(game, month, year, scheme) unless game.empty?
    end
    games
  end
end
