require_relative 'config'
require_relative 'game'
require_relative 'humble_data'
require_relative 'steam_store'

class HumbleChoiceGenerator
  attr_reader :game_list

  def initialize
    @game_list = []
    @ignore_list = []
  end

  # Convenience method to fire everything
  def generate
    generate_list
    populate_steam_ids
    HumbleGamesFiles.generate_output(@game_list)
  end

  # Generate game list
  def generate_list
    humble_data = HumbleData.new
    @game_list = humble_data.output
  end

  # Populate Steam Ids
  def populate_steam_ids
    steam_store = SteamStore.new
    @game_list = steam_store.populate_all_games(@game_list)
  end

  def read_ignore_list
    File.open(Config.ignore_list, 'r') do |f|
      f.each_line do |line|
        @ignore_list << line.downcase.chomp unless line.chars.first == '#'
      end
    end
  end

  def missing_steam_ids
    missing = {}
    @game_list.each do |game|
      # Create array for year if doesn't already exist
      missing[game.year] = [] if missing[game.year].nil?

      # Include if empty, and not on ignore list
      missing[game.year] << game if game.steam_id.nil? && !(@ignore_list.include? game.name.downcase)
    end

    missing
  end
end
