#frozen_string_literal: false
require 'ostruct'

module FunJSON
  class GenericObject < OpenStruct
    class << self
      alias [] new

      def json_creatable?
        @json_creatable
      end

      attr_writer :json_creatable

      def json_create(data)
        data = data.dup
        data.delete FunJSON.create_id
        self[data]
      end

      def from_hash(object)
        case
        when object.respond_to?(:to_hash)
          result = new
          object.to_hash.each do |key, value|
            result[key] = from_hash(value)
          end
          result
        when object.respond_to?(:to_ary)
          object.to_ary.map { |a| from_hash(a) }
        else
          object
        end
      end

      def load(source, proc = nil, opts = {})
        result = ::FunJSON.load(source, proc, opts.merge(:object_class => self))
        result.nil? ? new : result
      end

      def dump(obj, *args)
        ::FunJSON.dump(obj, *args)
      end
    end
    self.json_creatable = false

    def to_hash
      table
    end

    def [](name)
      __send__(name)
    end unless method_defined?(:[])

    def []=(name, value)
      __send__("#{name}=", value)
    end unless method_defined?(:[]=)

    def |(other)
      self.class[other.to_hash.merge(to_hash)]
    end

    def as_json(*)
      { FunJSON.create_id => self.class.name }.merge to_hash
    end

    def to_fun_json(*a)
      as_json.to_fun_json(*a)
    end
  end
end
