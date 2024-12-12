require './lib/humble_choice_generator'
require './lib/games_list_files'
require './lib/steam_spy'
require './lib/steam_store'

task :default do
  Rake::Task['generate_with_steam_ids_output'].invoke
end

# Generate games and ids
desc 'Generate Game objects with no Steam Ids'
task :generate_games_list do
  puts 'Generating Games with no Steam Ids'
  hc = HumbleChoiceGenerator.new
  hc.generate_list_no_ids
  GamesListFiles.write_output_files(hc.game_list)
end

desc 'Generate Game objects with no change to Steam Ids'
task :generate_games do
  puts 'Generating Games with no change to Steam Ids'
  hc = HumbleChoiceGenerator.new
  hc.generate_list
  GamesListFiles.write_output_files(hc.game_list)
end

desc 'Generate Game objects with Steam Ids (default)'
task :generate_with_steam_ids, [:month, :year] do |_t, args|
  m = args[:month]&.to_i
  y = args[:year]&.to_i

  puts 'Generate Games with Steam Ids'
  hc = HumbleChoiceGenerator.new
  hc.generate_list
  hc.add_steam_ids_for(m, y)
  GamesListFiles.write_output_files(hc.game_list)
end

desc 'Show missing Steam Ids'
task :missing_steam_ids do
  GamesListFiles.show_missing_steam_ids
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

# Convenience methods

desc 'Update all lists with Steam Ids including missing game output (default)'
task :generate_with_steam_ids_output do
  Rake::Task['generate_with_steam_ids'].invoke
  Rake::Task['missing_steam_ids'].invoke
end

desc 'Regenerate all listings and Steam datastore with missing game output'
task :regenerate do
  Rake::Task['get_steam'].invoke
  Rake::Task['generate_with_steam_ids'].invoke
  Rake::Task['missing_steam_ids'].invoke
end

# Add in steam tags

desc 'Regenerate all tags - slow'
task :regenerate_tags do
  spy = SteamSpy.new
  spy.add_all_tags
end

desc 'Add missing tags'
task :add_tags do
  spy = SteamSpy.new
  spy.add_missing_tags
end
