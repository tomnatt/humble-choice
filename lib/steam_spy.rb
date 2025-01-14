require_relative 'config'
require_relative 'game'

class SteamSpy
  attr_reader :game_list

  def initialize
    @game_list = GamesListFiles.read_games
  end

  def add_tags_for(month, year)
    @game_list.each do |game|
      # Skip this one unless year matches or no year set
      next unless year.nil? || game.year == year

      # Skip this one unless month matches or no month set
      next unless month.nil? || game.month.downcase == Date::MONTHNAMES[month].downcase

      game.tags = get_tags_for(game.steam_id) unless game.steam_id.nil?
      # Wait between each API call to avoid hammering the API
      sleep 1
    end
  end

  # for each game, if there is a steam id and no tags get them
  def add_missing_tags
    puts 'TODO'
    # @game_list.each do |game|
    #   if game.tags.empty? && !game.steam_id.nil?
    #     puts "#{game.name} no tags"
    #   end
    # end
  end

  private

  def steam_spy_api_url(appid)
    "https://steamspy.com/api.php?request=appdetails&appid=#{appid}"
  end

  def get_tags_for(appid)
    game_raw_json = Net::HTTP.get(URI.parse(steam_spy_api_url(appid)))
    game = JSON.parse(game_raw_json)
    game['tags'].empty? ? [] : game['tags'].keys
  end
end
