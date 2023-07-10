require 'csv'
require 'google_drive'
require 'yaml'
require_relative 'game'

class HumbleData
  attr_reader :output

  def initialize
    # Get the sheet:
    # https://docs.google.com/spreadsheets/d/1VZHuYi0OB6kc9Ma31RG57S7GqX2ND3Gk3FFfgDkToIk/edit#gid=142401517
    session = GoogleDrive::Session.from_service_account_key(ENV.fetch('HUMBLE_CHOICE_SERVICE_ACCOUNT_KEY'))
    @spreadsheet = session.spreadsheet_by_key('1VZHuYi0OB6kc9Ma31RG57S7GqX2ND3Gk3FFfgDkToIk')

    monthly = read_data(@spreadsheet.worksheets.first, 'monthly')
    choice = read_data(@spreadsheet.worksheets.last, 'choice')
    # Merge Monthly and Choice lists - on overlap, merge the clashing arrays
    @output = monthly.merge(choice) { |_y, m, c| m.concat(c) }
  end

  def read_data(worksheet, source)
    # Spreadsheet in format [ Month, Game ]
    # Skip first row (contains headers)
    game_hash = {}
    worksheet.rows.drop(1).each do |row|
      date = Date.parse(row[0])
      year = date.year
      month = date.strftime('%B')

      games = split_game_list(row[1])
      game_hash = create_game_objects(game_hash, games, month, year, source)
    end
    reverse_years(game_hash)
  end

  def reverse_years(game_hash)
    game_hash.each_key { |year| game_hash[year].reverse! }
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

  def create_game_objects(game_hash, games, month, year, scheme)
    game_hash[year] = [] unless game_hash[year]
    games.each do |game|
      game_hash[year] << Game.new(game, month, year, scheme) unless game.empty?
    end
    game_hash
  end
end
