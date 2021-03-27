require 'csv'
require 'yaml'

humble_present = 'data/humble-choice-2019-present.csv'

output = {}

CSV.read(humble_present, { headers: true }).each do |row|
  date = Date.parse(row['Month/Year'])
  year = date.year
  month = date.strftime('%B')

  next if year == 2019

  output[year] = [] unless output[year]

  games = []

  available_games = row['Available Games']&.split(';')
  available_games&.each { |game| games.concat(clean_games_list(game)) }

  games.each do |game|
    output[year] << { 'game' => { 'year' => year, 'month' => month, 'game' => game } } unless game.empty?
  end
end

output.each_key do |year|
  o = { year => output[year].reverse }

  f = File.open("output/humble-choice-#{year}.yml", 'w+')
  f << o.to_yaml
  f.close
end

BEGIN {

  def clean_games_list(game)
    games = []

    # Remove [ if first character
    game.delete_prefix!('[')

    if game.include?(' + ')
      game.split(' + ').each { |g| games << g.strip }
    elsif game.include?('] OR [')
      game.split('] OR [').each { |g| games << g.strip.delete_suffix(']') }
    else
      games << game.strip
    end

    games
  end

}
