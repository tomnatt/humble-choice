require 'json'
require 'net/http'
require 'uri'
require_relative './game'

class SteamIds
  def initialize
    steam_ids_url = 'http://api.steampowered.com/ISteamApps/GetAppList/v0002/?key=STEAMKEY&format=json'
    steam_ids_raw_json = Net::HTTP.get(URI.parse(steam_ids_url))

    @steam_ids = JSON.parse(steam_ids_raw_json)
  end

  def populate_all_games(output)
    output.each_value do |games_list|
      games_list.each do |game|
        g = @steam_ids['applist']['apps'].filter { |a| a['name'].strip.downcase == game.name.strip.downcase }
        game.steam_id = g.last['appid'] unless g.empty?
      end
    end

    output
  end
end
