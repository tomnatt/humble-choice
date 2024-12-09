require_relative 'config'
require_relative 'game'
require_relative 'humble_data'
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
    all_yaml_output = {}
    all_json_output = []

    @game_list.each_key do |year|
      # Prep output objects for all in one files
      all_yaml_output[year] = @game_list[year]
      all_json_output.push(*@game_list[year])

      # YAML output by year
      o = { year => @game_list[year] }
      File.write(Config.humble_year_file_yaml(year), o.to_yaml)

      # JSON output by year
      File.write(Config.humble_year_file_json(year), JSON.pretty_generate(@game_list[year]))
    end

    File.write(Config.humble_all_file_yaml, all_yaml_output.to_yaml)
    File.write(Config.humble_all_file_json, JSON.pretty_generate(all_json_output))
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
