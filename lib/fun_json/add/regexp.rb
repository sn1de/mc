#frozen_string_literal: false
unless defined?(::FunJSON::JSON_LOADED) and ::FunJSON::JSON_LOADED
  require 'fun_json/pure'
end

class Regexp

  # Deserializes FunJSON string by constructing new Regexp object with source
  # <tt>s</tt> (Regexp or String) and options <tt>o</tt> serialized by
  # <tt>to_fun_json</tt>
  def self.json_create(object)
    new(object['s'], object['o'])
  end

  # Returns a hash, that will be turned into a FunJSON object and represent this
  # object.
  def as_json(*)
    {
      FunJSON.create_id => self.class.name,
      'o'            => options,
      's'            => source,
    }
  end

  # Stores class name (Regexp) with options <tt>o</tt> and source <tt>s</tt>
  # (Regexp or String) as FunJSON string
  def to_fun_json(*args)
    as_json.to_fun_json(*args)
  end
end
