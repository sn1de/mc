#frozen_string_literal: false
unless defined?(::FunJSON::JSON_LOADED) and ::FunJSON::JSON_LOADED
  require 'fun_json/pure'
end

class Range

  # Deserializes FunJSON string by constructing new Range object with arguments
  # <tt>a</tt> serialized by <tt>to_fun_json</tt>.
  def self.json_create(object)
    new(*object['a'])
  end

  # Returns a hash, that will be turned into a FunJSON object and represent this
  # object.
  def as_json(*)
    {
      FunJSON.create_id  => self.class.name,
      'a'             => [ first, last, exclude_end? ]
    }
  end

  # Stores class name (Range) with FunJSON array of arguments <tt>a</tt> which
  # include <tt>first</tt> (integer), <tt>last</tt> (integer), and
  # <tt>exclude_end?</tt> (boolean) as FunJSON string.
  def to_fun_json(*args)
    as_json.to_fun_json(*args)
  end
end
