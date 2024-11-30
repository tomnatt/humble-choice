require './lib/humble_choice_generator'
require './lib/steam_store'

task :default do
  Rake::Task['generate'].invoke
end

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

desc 'Generate everything silently'
task :generate_silent do
  hc = HumbleChoiceGenerator.new
  hc.generate
end

desc 'Create Steam datastore'
task :get_steam do
  SteamStore.steam_ids
end
