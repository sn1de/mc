#frozen_string_literal: false
require 'test_helper'

class FunJSONExtParserTest < Test::Unit::TestCase
  if defined?(FunJSON::Ext::Parser)
    def test_allocate
      parser = FunJSON::Ext::Parser.new("{}")
      assert_raise(TypeError, '[ruby-core:35079]') do
        parser.__send__(:initialize, "{}")
      end
      parser = FunJSON::Ext::Parser.allocate
      assert_raise(TypeError, '[ruby-core:35079]') { parser.source }
    end
  end
end
