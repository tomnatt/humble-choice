require './code/humble_monthly'
# require './code/humble_choice'
require './code/game'

monthly = HumbleMonthly.new
# choice = HumbleChoice.new
# output = monthly.output + choice.output
output = monthly.output

output.each_key do |year|
  o = { year => output[year] }

  f = File.open("output/humble-choice-#{year}.yml", 'w+')
  f << o.to_yaml
  f.close
end
