require 'fileutils'
require 'json'
require 'net/http'
require 'sqlite3'
require 'uri'
require_relative 'config'
require_relative 'game'

class SteamStore
  attr_accessor :entries

  def initialize(load_file: true)
    @entries = []
    @db = nil

    return unless load_file

    if File.exist?(Config.steam_store_db)
      @db = SQLite3::Database.new(Config.steam_store_db)
    else
      puts 'Steam store DB not found - run get_steam first'
    end
  end

  def populate_steam_id(game)
    game.steam_id = find_id(game.name)
    game
  end

  def find_id(name)
    return nil if @db.nil?

    normalised = normalise_emoji_variants(name.downcase)
    row = @db.get_first_row('SELECT steam_id FROM apps WHERE normalised_name = ?', normalised)
    row&.first
  end

  def load_entries_from_steam_api
    last_appid = ''

    loop do
      steam_ids = load_json(last_appid)

      # Convert JSON objects to Game objects and store in @entries
      steam_ids['response']['apps'].each do |game|
        @entries << Game.new(game['name'], nil, nil, nil, game['appid'])
      end

      last_appid = steam_ids['response']['last_appid']

      # Stop this loop when there are no more results to fetch
      break if steam_ids['response']['have_more_results'].nil?

      # Brief pause to avoid hammering the API
      sleep(1)
    end
  end

  def save_entries
    # Write steam store to file
    File.open(Config.steam_store, 'w+') do |f|
      f << @entries.to_yaml
    end

    save_entries_to_db
  end

  def delete_entries_file
    FileUtils.rm_f(Config.steam_store)
    FileUtils.rm_f(Config.steam_store_db)
  end

  private

  def save_entries_to_db
    FileUtils.rm_f(Config.steam_store_db)
    db = SQLite3::Database.new(Config.steam_store_db)
    db.execute('CREATE TABLE apps (normalised_name TEXT PRIMARY KEY, steam_id INTEGER)')
    db.transaction do
      @entries.each do |game|
        normalised = normalise_emoji_variants(game.name.downcase)
        db.execute('INSERT OR IGNORE INTO apps (normalised_name, steam_id) VALUES (?, ?)', [normalised, game.steam_id])
      end
    end
    db.close
  end

  # Strip off the Variation Selector
  def normalise_emoji_variants(str)
    str.gsub('️', '')
  end

  def steam_api_url(last_appid_number = '')
    base = "https://api.steampowered.com/IStoreService/GetAppList/v1/?key=#{ENV.fetch('STEAM_API_KEY')}"
    "#{base}&max_results=50000&include_dlc=true&last_appid=#{last_appid_number}"
  end

  def load_json(last_appid)
    steam_ids_raw_json = Net::HTTP.get(URI.parse(steam_api_url(last_appid)))
    JSON.parse(steam_ids_raw_json)
  end
end
