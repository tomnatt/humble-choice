require_relative './humble_monthly'
require_relative './humble_choice'
require_relative './game'

monthly = HumbleMonthly.new
choice = HumbleChoice.new
output = monthly.output.merge(choice.output)

output.each_key do |year|
  o = { year => output[year] }

  f = File.open("output/humble-choice-#{year}.yml", 'w+')
  f << o.to_yaml
  f.close
end
