#frozen_string_literal: false
unless defined?(::FunJSON::JSON_LOADED) and ::FunJSON::JSON_LOADED
  require 'fun_json/pure'
end

class Exception

  # Deserializes FunJSON string by constructing new Exception object with message
  # <tt>m</tt> and backtrace <tt>b</tt> serialized with <tt>to_fun_json</tt>
  def self.json_create(object)
    result = new(object['m'])
    result.set_backtrace object['b']
    result
  end

  # Returns a hash, that will be turned into a FunJSON object and represent this
  # object.
  def as_json(*)
    {
      FunJSON.create_id => self.class.name,
      'm'            => message,
      'b'            => backtrace,
    }
  end

  # Stores class name (Exception) with message <tt>m</tt> and backtrace array
  # <tt>b</tt> as FunJSON string
  def to_fun_json(*args)
    as_json.to_fun_json(*args)
  end
end
