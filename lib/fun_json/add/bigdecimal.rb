#frozen_string_literal: false
unless defined?(::FunJSON::JSON_LOADED) and ::FunJSON::JSON_LOADED
  require 'fun_json/pure'
end
defined?(::BigDecimal) or require 'bigdecimal'

class BigDecimal
  # Import a FunJSON Marshalled object.
  #
  # method used for FunJSON marshalling support.
  def self.json_create(object)
    BigDecimal._load object['b']
  end

  # Marshal the object to FunJSON.
  #
  # method used for FunJSON marshalling support.
  def as_json(*)
    {
      FunJSON.create_id => self.class.name,
      'b'            => _dump,
    }
  end

  # return the FunJSON value
  def to_fun_json(*args)
    as_json.to_fun_json(*args)
  end
end
