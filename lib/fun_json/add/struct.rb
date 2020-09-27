#frozen_string_literal: false
unless defined?(::FunJSON::JSON_LOADED) and ::FunJSON::JSON_LOADED
  require 'fun_json/pure'
end

class Struct

  # Deserializes FunJSON string by constructing new Struct object with values
  # <tt>v</tt> serialized by <tt>to_fun_json</tt>.
  def self.json_create(object)
    new(*object['v'])
  end

  # Returns a hash, that will be turned into a FunJSON object and represent this
  # object.
  def as_json(*)
    klass = self.class.name
    klass.to_s.empty? and raise FunJSON::JSONError, "Only named structs are supported!"
    {
      FunJSON.create_id => klass,
      'v'            => values,
    }
  end

  # Stores class name (Struct) with Struct values <tt>v</tt> as a FunJSON string.
  # Only named structs are supported.
  def to_fun_json(*args)
    as_json.to_fun_json(*args)
  end
end
