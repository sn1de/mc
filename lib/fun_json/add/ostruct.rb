#frozen_string_literal: false
unless defined?(::FunJSON::JSON_LOADED) and ::FunJSON::JSON_LOADED
  require 'fun_json/pure'
end
require 'ostruct'

class OpenStruct

  # Deserializes FunJSON string by constructing new Struct object with values
  # <tt>t</tt> serialized by <tt>to_fun_json</tt>.
  def self.json_create(object)
    new(object['t'] || object[:t])
  end

  # Returns a hash, that will be turned into a FunJSON object and represent this
  # object.
  def as_json(*)
    klass = self.class.name
    klass.to_s.empty? and raise FunJSON::JSONError, "Only named structs are supported!"
    {
      FunJSON.create_id => klass,
      't'            => table,
    }
  end

  # Stores class name (OpenStruct) with this struct's values <tt>t</tt> as a
  # FunJSON string.
  def to_fun_json(*args)
    as_json.to_fun_json(*args)
  end
end
