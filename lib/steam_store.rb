require 'json'
require 'net/http'
require 'uri'
require_relative 'game'

class SteamStore
  def self.steam_ids
    entries = []
    steam_api_url = "https://api.steampowered.com/IStoreService/GetAppList/v1/?key=#{ENV.fetch('STEAM_API_KEY')}&max_results=50000&last_appid="
    last_appid = ''

    loop do
      steam_ids_url = "#{steam_api_url}#{last_appid}"
      steam_ids_raw_json = Net::HTTP.get(URI.parse(steam_ids_url))
      steam_ids = JSON.parse(steam_ids_raw_json)

      steam_ids['response']['apps'].each do |game|
        g = Game.new(game['name'], nil, nil, nil)
        g.steam_id = game['appid']
        entries << g
      end

      last_appid = steam_ids['response']['last_appid']

      # Stop this loop when there are no more results to fetch
      break if steam_ids['response']['have_more_results'].nil?

      # Brief pause to avoid hammering the API
      sleep(1)
    end

    # Write steam store to file
    f = File.open('steam/steam-store.yml', 'w+')
    f << entries.to_yaml
    f.close
  end
end
