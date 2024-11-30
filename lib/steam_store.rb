require 'json'
require 'net/http'
require 'uri'
require_relative 'game'

class SteamStore
  attr_accessor :entries

  def initialize(load_file: true)
    @entries = []
    @ids_file = 'steam/steam-store.yml'
    # @ids_file = 'steam/test-store.yml'

    load_entries_from_file if load_file
  end

  def load_entries_from_file
    if File.exist?(@ids_file)
      @entries = YAML.load_file(@ids_file, permitted_classes: [Game])
    else
      puts 'Load entries from Steam API'
    end
  end

  def populate_all_games(output)
    output.each_value do |games_list|
      games_list.each do |game|
        game.steam_id = find_id(game.name)
      end
    end

    output
  end

  def find_id(name)
    g = @entries.select { |game| game.name.downcase == name.downcase }

    # Return nil if we don't find the game
    return nil if g.empty?

    g.first.steam_id
  end

  def load_entries_from_steam_api
    last_appid = ''

    loop do
      steam_ids = load_json(last_appid)

      # Convert JSON objects to Game objects and store in @entries
      steam_ids['response']['apps'].each do |game|
        @entries << Game.new(game['name'], nil, nil, nil, game['appid'])
      end

      last_appid = steam_ids['response']['last_appid']

      # Stop this loop when there are no more results to fetch
      break if steam_ids['response']['have_more_results'].nil?

      # Brief pause to avoid hammering the API
      sleep(1)
    end
  end

  def save_entries
    # Write steam store to file
    f = File.open(@ids_file, 'w+')
    f << @entries.to_yaml
    f.close
  end

  def delete_entries_file
    FileUtils.rm_f(@ids_file)
  end

  private

  def steam_api_url(last_appid = '')
    steam_api_url = "https://api.steampowered.com/IStoreService/GetAppList/v1/?key=#{ENV.fetch('STEAM_API_KEY')}&max_results=50000&last_appid="
    "#{steam_api_url}#{last_appid}"
  end

  def load_json(last_appid)
    steam_ids_raw_json = Net::HTTP.get(URI.parse(steam_api_url(last_appid)))
    JSON.parse(steam_ids_raw_json)
  end
end
