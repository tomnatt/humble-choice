require './lib/humble_choice_generator'
require './lib/games_list_files'
require './lib/steam_store'

task :default do
  Rake::Task['generate'].invoke
end

# Generate games and ids

desc 'Generate Game objects, YAML and JSON with no Steam Ids'
task :generate_games do
  puts 'Generating Games with no Steam Ids'
  hc = HumbleChoiceGenerator.new
  hc.generate_list
  GamesListFiles.write_output_files(hc.game_list)
end

desc 'Generate everything with output (default)'
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

  puts "\n"

  # Output count of missing games
  total = 0
  missing.keys.sort.each do |year|
    puts "#{year}: #{missing[year].count}" unless missing[year].empty?
    total += missing[year].count
  end

  puts "Total: #{total}"
end

desc 'Generate everything silently'
task :generate_silent do
  hc = HumbleChoiceGenerator.new
  hc.generate
end

# Steam datastore

desc 'Create Steam datastore'
task get_steam: :delete_steam do
  store = SteamStore.new(load_file: false)
  store.load_entries_from_steam_api
  store.save_entries
end

desc 'Delete Steam datastore'
task :delete_steam do
  store = SteamStore.new(load_file: false)
  store.delete_entries_file
end

# Full regeneration

desc 'Regenerate all listings with no tags'
task :regenerate do
  Rake::Task['get_steam'].invoke
  Rake::Task['generate'].invoke
end

desc 'Regenerate all listings with no tags - no output'
task :regenerate_silent do
  Rake::Task['get_steam'].invoke
  Rake::Task['generate_silent'].invoke
end
