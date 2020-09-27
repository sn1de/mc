#frozen_string_literal: false
unless defined?(::FunJSON::JSON_LOADED) and ::FunJSON::JSON_LOADED
  require 'fun_json/pure'
end
require 'date'

class Date

  # Deserializes FunJSON string by converting Julian year <tt>y</tt>, month
  # <tt>m</tt>, day <tt>d</tt> and Day of Calendar Reform <tt>sg</tt> to Date.
  def self.json_create(object)
    civil(*object.values_at('y', 'm', 'd', 'sg'))
  end

  alias start sg unless method_defined?(:start)

  # Returns a hash, that will be turned into a FunJSON object and represent this
  # object.
  def as_json(*)
    {
      FunJSON.create_id => self.class.name,
      'y' => year,
      'm' => month,
      'd' => day,
      'sg' => start,
    }
  end

  # Stores class name (Date) with Julian year <tt>y</tt>, month <tt>m</tt>, day
  # <tt>d</tt> and Day of Calendar Reform <tt>sg</tt> as FunJSON string
  def to_fun_json(*args)
    as_json.to_fun_json(*args)
  end
end
