require './lib/humble_choice_generator'

desc 'Generate Game objects and YAML with no Steam Ids'
task :generate_games do
  puts 'Generating Games with no Steam Ids'
  hc = HumbleChoiceGenerator.new
  hc.generate_list
  hc.generate_yaml
end

desc 'Generate everything with output'
task :generate do
  puts 'Generating...'
  hc = HumbleChoiceGenerator.new
  hc.generate

  # Output list of games with missing Steam Ids, skipping the ignore list
  hc.read_ignore_list
  missing = hc.missing_steam_ids
  missing.keys.sort.each do |year|
    unless missing[year].empty?
      o = { year => missing[year] }.to_yaml
      puts o
    end
  end
end

# Generate everything silently
task :default do
  hc = HumbleChoiceGenerator.new
  hc.generate
end
