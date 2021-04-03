require 'yaml'

class Game
  attr_accessor :year, :month, :name, :steam_id

  def initialize(name, month, year)
    @name = name
    @month = month
    @year = year
    @steam_id = nil
  end

  def to_yaml
    'foo'
  end
end
