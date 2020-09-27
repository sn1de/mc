unless defined?(::FunJSON::JSON_LOADED) and ::FunJSON::JSON_LOADED
  require 'fun_json/pure'
end
defined?(::Set) or require 'set'

class Set
  # Import a FunJSON Marshalled object.
  #
  # method used for FunJSON marshalling support.
  def self.json_create(object)
    new object['a']
  end

  # Marshal the object to FunJSON.
  #
  # method used for FunJSON marshalling support.
  def as_json(*)
    {
      FunJSON.create_id => self.class.name,
      'a'            => to_a,
    }
  end

  # return the FunJSON value
  def to_fun_json(*args)
    as_json.to_fun_json(*args)
  end
end

