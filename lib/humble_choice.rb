require 'csv'
require 'google_drive'
require 'yaml'
require_relative './game'

class HumbleChoice
  attr_reader :output

  def initialize
    # TODO: improve this
    session = GoogleDrive::Session.from_service_account_key('keys/humble-choice-25629b26b6b6.json')

    # Get the sheet:
    # https://docs.google.com/spreadsheets/d/1VZHuYi0OB6kc9Ma31RG57S7GqX2ND3Gk3FFfgDkToIk/edit#gid=142401517
    @worksheet = session.spreadsheet_by_key('1VZHuYi0OB6kc9Ma31RG57S7GqX2ND3Gk3FFfgDkToIk').worksheets.last
    @output = {}

    read_choice_data
  end

  def read_choice_data
    # Spreadsheet in format [ Month, Game ]
    # Skip first row (contains headers)
    @worksheet.rows.drop(1).each do |row|
      date = Date.parse(row[0])
      year = date.year
      month = date.strftime('%B')

      next if year == 2019

      games = []
      split_game_list(row[1], games)

      create_game_objects(games, month, year)
    end
    reverse_years
  end

  def reverse_years
    @output.each_key { |year| @output[year].reverse! }
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
