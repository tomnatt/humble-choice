require 'yaml'

class Game
  attr_accessor :year, :month, :name, :humble_scheme, :steam_id

  def initialize(name, month, year, scheme, steam_id = nil)
    @name = name
    @month = month
    @year = year
    @humble_scheme = scheme
    @steam_id = steam_id
  end
end
