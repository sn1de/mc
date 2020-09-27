require 'fun_json/common'

module FunJSON
  # This module holds all the modules/classes that implement FunJSON's
  # functionality as C extensions.
  module Ext
    require 'fun_json/ext/parser'
    require 'fun_json/ext/generator'
    $DEBUG and warn "Using Ext extension for FunJSON."
    FunJSON.parser = Parser
    FunJSON.generator = Generator
  end

  JSON_LOADED = true unless defined?(::FunJSON::JSON_LOADED)
end
