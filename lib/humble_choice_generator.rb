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
    generate_output
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

  # Create all YAML and JSON files
  def generate_output
    generate_output_by_year
    generate_output_all
  end

  # Create YAML and JSON year files
  def generate_output_by_year
    @game_list.each_key do |year|
      o = { year => @game_list[year] }

      yaml_file = File.open("output/yaml/humble-choice-#{year}.yml", 'w+')
      yaml_file << o.to_yaml
      yaml_file.close

      json_file = File.open("output/json/humble-choice-#{year}.json", 'w+')
      json_file << JSON.pretty_generate(@game_list[year])
      json_file.close
    end
  end

  # Create YAML and JSON all in one files
  def generate_output_all
    yaml_output = {}
    json_output = []
    @game_list.each_key do |year|
      yaml_output[year] = @game_list[year]
      json_output.push(*@game_list[year])
    end

    yaml_file = File.open('output/yaml/humble-choice-all.yml', 'w+')
    yaml_file << yaml_output.to_yaml
    yaml_file.close

    json_file = File.open('output/json/humble-choice-all.json', 'w+')
    json_file << JSON.pretty_generate(json_output)
    json_file.close
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
