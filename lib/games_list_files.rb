require_relative 'config'
require_relative 'game'

class GamesListFiles
  # Create all YAML and JSON files
  def self.write_output_files(game_list)
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

  def self.show_missing(field)
    missing = missing_list(field)

    show_missing_by_year(missing)
    puts "\n"
    show_missing_counts(missing)
  end

  def self.show_missing_by_year(missing)
    missing.keys.sort.each do |year|
      unless missing[year].empty?
        o = { year => missing[year] }.to_yaml
        puts o
      end
    end
  end

  def self.show_missing_counts(missing)
    # Output count of missing games
    total = 0
    missing.keys.sort.each do |year|
      puts "#{year}: #{missing[year].count}" unless missing[year].empty?
      total += missing[year].count
    end

    puts "Total: #{total}"
  end

  def self.missing_list(field)
    ignore_list = read_ignore_list
    existing_list = read_games

    missing = {}
    existing_list.each do |game|
      # Create array for year if doesn't already exist
      missing[game.year] = [] if missing[game.year].nil?

      # Include if missing, and not on ignore list
      missing[game.year] << game if missing?(field, game) && !(ignore_list.include? game.name.downcase)
    end
    missing
  end

  def self.missing?(field, game)
    # Criteria for information missing for a Steam Id vs Tags
    if field == 'steam_ids'
      game.steam_id.nil?
    else
      game.tags.nil? || game.tags.empty?
    end
  end

  def self.read_ignore_list
    ignore_list = []
    File.open(Config.ignore_list, 'r') do |f|
      f.each_line do |line|
        ignore_list << line.downcase.chomp unless line.chars.first == '#'
      end
    end
    ignore_list
  end
end
