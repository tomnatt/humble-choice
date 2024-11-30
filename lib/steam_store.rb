require 'json'
require 'net/http'
require 'uri'
require_relative 'game'

class SteamStore
  attr_accessor :entries

  def initialize
    @entries = []
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
    f = File.open('steam/steam-store.yml', 'w+')
    f << @entries.to_yaml
    f.close
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
