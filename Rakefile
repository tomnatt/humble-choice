require './lib/humble_choice_generator'
require './lib/games_list_files'
require './lib/steam_store'

task :default do
  Rake::Task['generate_with_steam_ids'].invoke
end

# Generate games and ids

desc 'Generate Game objects, YAML and JSON with no Steam Ids'
task :generate_games do
  puts 'Generating Games with no Steam Ids'
  hc = HumbleChoiceGenerator.new
  hc.generate_list
  GamesListFiles.write_output_files(hc.game_list)
end

desc 'Generate Game objects with Steam Ids (default)'
task :generate_with_steam_ids, [:month, :year] do |_t, args|
  m = args[:month]
  y = args[:year].to_i

  puts 'Generate Games with Steam Ids'
  hc = HumbleChoiceGenerator.new
  hc.generate_list

  if m.nil? && y.nil?
    hc.add_all_steam_ids
  else
    hc.add_steam_ids_for(m, y)
  end

  GamesListFiles.write_output_files(hc.game_list)

  # TODO - refactor to another method

  # Output missing ids
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
  Rake::Task['generate_with_steam_ids'].invoke
end
