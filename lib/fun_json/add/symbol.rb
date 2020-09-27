#frozen_string_literal: false
unless defined?(::FunJSON::JSON_LOADED) and ::FunJSON::JSON_LOADED
  require 'fun_json/pure'
end

class Symbol
  # Returns a hash, that will be turned into a FunJSON object and represent this
  # object.
  def as_json(*)
    {
      FunJSON.create_id => self.class.name,
      's'            => to_s,
    }
  end

  # Stores class name (Symbol) with String representation of Symbol as a FunJSON string.
  def to_fun_json(*a)
    as_json.to_fun_json(*a)
  end

  # Deserializes FunJSON string by converting the <tt>string</tt> value stored in the object to a Symbol
  def self.json_create(o)
    o['s'].to_sym
  end
end
