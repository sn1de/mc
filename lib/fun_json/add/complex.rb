#frozen_string_literal: false
unless defined?(::FunJSON::JSON_LOADED) and ::FunJSON::JSON_LOADED
  require 'fun_json/pure'
end
defined?(::Complex) or require 'complex'

class Complex

  # Deserializes FunJSON string by converting Real value <tt>r</tt>, imaginary
  # value <tt>i</tt>, to a Complex object.
  def self.json_create(object)
    Complex(object['r'], object['i'])
  end

  # Returns a hash, that will be turned into a FunJSON object and represent this
  # object.
  def as_json(*)
    {
      FunJSON.create_id => self.class.name,
      'r'            => real,
      'i'            => imag,
    }
  end

  # Stores class name (Complex) along with real value <tt>r</tt> and imaginary value <tt>i</tt> as FunJSON string
  def to_fun_json(*args)
    as_json.to_fun_json(*args)
  end
end
