require_relative 'humble_games_files'
require_relative 'config'
require_relative 'game'

class SteamSpy
  def initialize
    @game_list = HumbleGamesFiles.read_games
  end

  def add_all_tags
    @game_list.each do |game|
      game.tags = get_tags_for(game.steam_id) unless game.steam_id.nil?
      # Wait between each API call to avoid hammering the API
      sleep 1
      # Write to file each time - inefficient but saves output ongoing
      HumbleGamesFiles.generate_output(@game_list)
    end
  end

  # for each game, if there is a steam id and no tags get them
  def add_missing_tags
    @game_list.each do |game|
      if game.tags.empty? && !game.steam_id.nil?
        puts "#{game.name} no tags"
      end
    end
  end

  private

  def steam_spy_api_url(appid)
    "https://steamspy.com/api.php?request=appdetails&appid=#{appid}"
  end

  def get_tags_for(appid)
    game_raw_json = Net::HTTP.get(URI.parse(steam_spy_api_url(appid)))
    game = JSON.parse(game_raw_json)

    puts "#{game['name']} - #{game['appid']}"
    game['tags'].empty? ? [] : game['tags'].keys
  end
end
