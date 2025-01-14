require_relative 'config'
require_relative 'game'
require_relative 'google_data'
require_relative 'steam_store'

class HumbleChoiceGenerator
  attr_reader :game_list

  def initialize
    @game_list = []
  end

  # Generate game list fresh
  def generate_list_no_ids
    google_data = GoogleData.new
    @game_list = google_data.games_list
  end

  # Generate game list for action
  def generate_list
    generate_list_no_ids

    # Get the existing list and add into working list
    existing_list = GamesListFiles.read_games
    @game_list.map { |game| existing_list.select { |existing_game| game.name.downcase == existing_game.name.downcase } }
  end

  def add_all_steam_ids
    steam_store = SteamStore.new
    @game_list.map { |game| steam_store.populate_steam_id(game) }
  end

  def add_steam_ids_for(month, year)
    steam_store = SteamStore.new
    @game_list.map do |game|
      if game.year == year
        steam_store.populate_steam_id(game)
      end
    end
  end

  def missing_steam_ids
    ignore_list = read_ignore_list

    missing = {}
    @game_list.each do |game|
      # Create array for year if doesn't already exist
      missing[game.year] = [] if missing[game.year].nil?

      # Include if empty, and not on ignore list
      missing[game.year] << game if game.steam_id.nil? && !(ignore_list.include? game.name.downcase)
    end

    missing
  end

  def read_ignore_list
    ignore_list = []
    File.open(Config.ignore_list, 'r') do |f|
      f.each_line do |line|
        ignore_list << line.downcase.chomp unless line.chars.first == '#'
      end
    end
    ignore_list
  end
end
