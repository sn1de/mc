require 'fun_json/common'

module FunJSON
  # This module holds all the modules/classes that implement FunJSON's
  # functionality in pure ruby.
  module Pure
    require 'fun_json/pure/parser'
    require 'fun_json/pure/generator'
    $DEBUG and warn "Using Pure library for FunJSON."
    FunJSON.parser = Parser
    FunJSON.generator = Generator
  end

  FunJSON_LOADED = true unless defined?(::FunJSON::JSON_LOADED)
end
