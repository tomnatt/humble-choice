require 'csv'
require 'yaml'

humble_montly = 'data/humble-choice-2015-2019.csv'

output = {}

CSV.read(humble_montly, { headers: true }).each do |row|
  date = Date.parse(row['Month/Year'])
  year = date.year
  month = date.strftime('%B')

  output[year] = [] unless output[year]

  games = []

  row['Early Unlock(s)'].split(';').each { |game| games.concat(clean_games_list(game)) }
  row['Other Games'].split(';').each { |game| games.concat(clean_games_list(game)) }

  games.each do |game|
    output[year] << { game: { year: year, month: month, game: game } } unless game.empty?
  end
end

output.each_key do |year|
  o = { year => output[year] }

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
      game.split('] OR [').each { |g| games << g.strip }
    else
      games << game.strip
    end

    games
  end

}
