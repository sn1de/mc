#frozen_string_literal: false
unless defined?(::FunJSON::JSON_LOADED) and ::FunJSON::JSON_LOADED
  require 'fun_json/pure'
end
defined?(::Rational) or require 'rational'

class Rational
  # Deserializes FunJSON string by converting numerator value <tt>n</tt>,
  # denominator value <tt>d</tt>, to a Rational object.
  def self.json_create(object)
    Rational(object['n'], object['d'])
  end

  # Returns a hash, that will be turned into a FunJSON object and represent this
  # object.
  def as_json(*)
    {
      FunJSON.create_id => self.class.name,
      'n'            => numerator,
      'd'            => denominator,
    }
  end

  # Stores class name (Rational) along with numerator value <tt>n</tt> and denominator value <tt>d</tt> as FunJSON string
  def to_fun_json(*args)
    as_json.to_fun_json(*args)
  end
end
