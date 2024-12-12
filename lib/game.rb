require 'yaml'

class Game
  attr_accessor :year, :month, :name, :humble_scheme, :steam_id, :tags

  def initialize(name, month, year, scheme, steam_id = nil)
    @name = name
    @month = month
    @year = year
    @humble_scheme = scheme
    @steam_id = steam_id
    @tags = []
  end

  def as_json(_options = {})
    {
      name:          @name,
      month:         @month,
      year:          @year,
      humble_scheme: @humble_scheme,
      steam_id:      @steam_id
    }
  end

  def to_json(*options)
    as_json(*options).to_json(*options)
  end
end
