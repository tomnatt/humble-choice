require 'json'
require 'net/http'
require 'uri'
require_relative 'game'

class SteamIds
  def initialize
    # steam_ids_url = 'http://api.steampowered.com/ISteamApps/GetAppList/v0002/?key=STEAMKEY&format=json'
    steam_ids_url = 'https://api.steampowered.com/ISteamApps/GetAppList/v0002/'
    steam_ids_raw_json = Net::HTTP.get(URI.parse(steam_ids_url))

    @steam_ids = JSON.parse(steam_ids_raw_json)
  end

  def populate_all_games(output)
    output.each_value do |games_list|
      games_list.each do |game|
        # Match game and if it matches more than once, take the highest value - should be latest entry
        matches = match_game(game)
        game.steam_id = matches.max_by { |g| g['appid'] }['appid'] unless matches.empty?
      end
    end

    output
  end

  # Match game name against Steam ID list
  def match_game(game)
    @steam_ids['applist']['apps'].filter { |a| a['name'].strip.downcase == game.name.strip.downcase }
  end
end
