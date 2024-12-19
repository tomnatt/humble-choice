class Config
  def self.humble_all_file_yaml
    'output/yaml/humble-choice-all.yml'
  end

  def self.humble_all_file_json
    'output/json/humble-choice-all.json'
  end

  def self.ignore_list
    'ignore-list.txt'
  end

  def self.humble_year_file_yaml(year)
    "output/yaml/humble-choice-#{year}.yml"
  end

  def self.humble_year_file_json(year)
    "output/json/humble-choice-#{year}.json"
  end

  def self.years
    (2015..2024).to_a
  end

  def self.steam_store
    'steam/steam-store.yml'
  end
end
