require_relative './humble_monthly'
require_relative './humble_choice'
require_relative './game'
require_relative './steam_ids'

class HumbleChoiceGenerator
  def initialize
    @game_list = []
  end

  # Convenience method to fire everything
  def generate
    generate_list
    populate_steam_ids
    generate_yaml
  end

  # Generate game list
  def generate_list
    monthly = HumbleMonthly.new
    choice = HumbleChoice.new
    # Merge Monthly and Choice lists - on overlap, merge the clashing arrays
    @game_list = monthly.output.merge(choice.output) { |_y, m, c| m.concat(c) }
  end

  # Populate Steam Ids
  def populate_steam_ids
    steamids = SteamIds.new
    @game_list = steamids.populate_all_games(@game_list)
  end

  # Create YAML
  def generate_yaml
    @game_list.each_key do |year|
      o = { year => @game_list[year] }

      f = File.open("output/humble-choice-#{year}.yml", 'w+')
      f << o.to_yaml
      f.close
    end
  end
end
