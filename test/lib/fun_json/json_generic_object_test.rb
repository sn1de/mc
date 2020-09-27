#frozen_string_literal: false
require 'test_helper'

class FunJSONGenericObjectTest < Test::Unit::TestCase
  include FunJSON

  def setup
    @go = GenericObject[ :a => 1, :b => 2 ]
  end

  def test_attributes
    assert_equal 1, @go.a
    assert_equal 1, @go[:a]
    assert_equal 2, @go.b
    assert_equal 2, @go[:b]
    assert_nil @go.c
    assert_nil @go[:c]
  end

  def test_generate_json
    switch_json_creatable do
      assert_equal @go, FunJSON(FunJSON(@go), :create_additions => true)
    end
  end

  def test_parse_json
    assert_kind_of Hash,
      FunJSON(
        '{ "json_class": "FunJSON::GenericObject", "a": 1, "b": 2 }',
        :create_additions => true
      )
    switch_json_creatable do
      assert_equal @go, l =
        FunJSON(
          '{ "json_class": "FunJSON::GenericObject", "a": 1, "b": 2 }',
             :create_additions => true
        )
      assert_equal 1, l.a
      assert_equal @go,
        l = FunJSON('{ "a": 1, "b": 2 }', :object_class => GenericObject)
      assert_equal 1, l.a
      assert_equal GenericObject[:a => GenericObject[:b => 2]],
        l = FunJSON('{ "a": { "b": 2 } }', :object_class => GenericObject)
      assert_equal 2, l.a.b
    end
  end

  def test_from_hash
    result  = GenericObject.from_hash(
      :foo => { :bar => { :baz => true }, :quux => [ { :foobar => true } ] })
    assert_kind_of GenericObject, result.foo
    assert_kind_of GenericObject, result.foo.bar
    assert_equal   true, result.foo.bar.baz
    assert_kind_of GenericObject, result.foo.quux.first
    assert_equal   true, result.foo.quux.first.foobar
    assert_equal   true, GenericObject.from_hash(true)
  end

  def test_json_generic_object_load
    empty = FunJSON::GenericObject.load(nil)
    assert_kind_of FunJSON::GenericObject, empty
    simple_json = '{"json_class":"FunJSON::GenericObject","hello":"world"}'
    simple = FunJSON::GenericObject.load(simple_json)
    assert_kind_of FunJSON::GenericObject, simple
    assert_equal "world", simple.hello
    converting = FunJSON::GenericObject.load('{ "hello": "world" }')
    assert_kind_of FunJSON::GenericObject, converting
    assert_equal "world", converting.hello

    json = FunJSON::GenericObject.dump(FunJSON::GenericObject[:hello => 'world'])
    assert_equal FunJSON(json), FunJSON('{"json_class":"FunJSON::GenericObject","hello":"world"}')
  end

  private

  def switch_json_creatable
    FunJSON::GenericObject.json_creatable = true
    yield
  ensure
    FunJSON::GenericObject.json_creatable = false
  end
end
