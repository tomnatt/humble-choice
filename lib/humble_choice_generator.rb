require_relative 'humble_data'
require_relative 'game'
require_relative 'steam_store'

class HumbleChoiceGenerator
  def initialize
    @game_list = []
    @ignore_list = []
  end

  # Convenience method to fire everything
  def generate
    generate_list
    populate_steam_ids
    generate_yaml
    generate_json
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

  # Create YAML
  def generate_yaml
    @game_list.each_key do |year|
      o = { year => @game_list[year] }

      f = File.open("output/humble-choice-#{year}.yml", 'w+')
      f << o.to_yaml
      f.close
    end
  end

  # Create JSON
  def generate_json
    @game_list.each_key do |year|
      f = File.open("output/humble-choice-#{year}.json", 'w+')
      f << JSON.pretty_generate(@game_list[year])
      f.close
    end
  end

  def read_ignore_list
    f = File.open('ignore-list.txt', 'r')
    f.each_line do |line|
      @ignore_list << line.downcase.chomp unless line.chars.first == '#'
    end
  end

  def missing_steam_ids
    missing = {}
    @game_list.each_key do |year|
      missing[year] = []

      @game_list[year].each do |game|
        # Include if empty, and not on ignore list
        missing[year] << game if game.steam_id.nil? && !(@ignore_list.include? game.name.downcase)
      end
    end

    missing
  end
end
