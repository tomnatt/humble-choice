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

  row['Early Unlock(s)'].split(';').each { |game| games << game.strip }
  row['Other Games'].split(';').each do |game|
    if game.include?(' + ')
      game.split(' + ').each { |g| games << g.strip }
    else
      games << game.strip
    end
  end

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
