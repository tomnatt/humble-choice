require_relative 'config'
require_relative 'game'

class HumbleGamesFiles
  # Create all YAML and JSON files
  def self.generate_output(game_list)
    games_by_year = {}
    game_list.each do |game|
      games_by_year[game.year] = [] if games_by_year[game.year].nil?
      games_by_year[game.year] << game
    end

    write_year_games_files(game_list)
    write_all_games_files(games_by_year)
  end

  def self.read_games
    YAML.load_file(Config.humble_all_file_yaml, permitted_classes: [Game])
  end

  def self.write_year_games_files(game_list)
    # YAML and JSON output all games
    File.write(Config.humble_all_file_yaml, game_list.to_yaml)
    File.write(Config.humble_all_file_json, JSON.pretty_generate(game_list))
  end

  def self.write_all_games_files(games_by_year)
    # YAML and JSON output by year
    Config.years.each do |year|
      File.write(Config.humble_year_file_yaml(year), games_by_year[year].to_yaml)
      File.write(Config.humble_year_file_json(year), JSON.pretty_generate(games_by_year[year]))
    end
  end
end
