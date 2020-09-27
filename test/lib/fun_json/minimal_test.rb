#frozen_string_literal: false
require 'test_helper'
require 'fun_json'

class FunJSONMinimalTest < Test::Unit::TestCase
  def test_minimal_0
    string = <<~JSON
      {"key":"value"}
    JSON

    assert FunJSON.parse(string)
  end

  def test_minimal_1
    string = <<~JSON
      {  "key": "value" }
    JSON

    assert FunJSON.parse(string)
  end

  # FIXME: These two test cases are the ones that fail
  def test_minimal_2
    string = <<~JSON
      {"key" : "value"}
    JSON

    assert FunJSON.parse(string)
  end

  def test_minimal_3
    string = <<~JSON
      {  "key" /* must be lowercase */ : "value" }
    JSON

    assert FunJSON.parse(string)
  end

  def test_minimal_4
    string = <<~JSON
      {  "key" : /* must be lowercase */ "value" }
    JSON

    assert FunJSON.parse(string)
  end

end
