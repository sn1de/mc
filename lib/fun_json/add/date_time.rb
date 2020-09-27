#frozen_string_literal: false
unless defined?(::FunJSON::JSON_LOADED) and ::FunJSON::JSON_LOADED
  require 'fun_json/pure'
end
require 'date'

class DateTime

  # Deserializes FunJSON string by converting year <tt>y</tt>, month <tt>m</tt>,
  # day <tt>d</tt>, hour <tt>H</tt>, minute <tt>M</tt>, second <tt>S</tt>,
  # offset <tt>of</tt> and Day of Calendar Reform <tt>sg</tt> to DateTime.
  def self.json_create(object)
    args = object.values_at('y', 'm', 'd', 'H', 'M', 'S')
    of_a, of_b = object['of'].split('/')
    if of_b and of_b != '0'
      args << Rational(of_a.to_i, of_b.to_i)
    else
      args << of_a
    end
    args << object['sg']
    civil(*args)
  end

  alias start sg unless method_defined?(:start)

  # Returns a hash, that will be turned into a FunJSON object and represent this
  # object.
  def as_json(*)
    {
      FunJSON.create_id => self.class.name,
      'y' => year,
      'm' => month,
      'd' => day,
      'H' => hour,
      'M' => min,
      'S' => sec,
      'of' => offset.to_s,
      'sg' => start,
    }
  end

  # Stores class name (DateTime) with Julian year <tt>y</tt>, month <tt>m</tt>,
  # day <tt>d</tt>, hour <tt>H</tt>, minute <tt>M</tt>, second <tt>S</tt>,
  # offset <tt>of</tt> and Day of Calendar Reform <tt>sg</tt> as FunJSON string
  def to_fun_json(*args)
    as_json.to_fun_json(*args)
  end
end


