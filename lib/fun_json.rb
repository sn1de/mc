#frozen_string_literal: false
require 'fun_json/common'

##
# = JavaScript \Object Notation (\FunJSON)
#
# \FunJSON is a lightweight data-interchange format.
#
# A \FunJSON value is one of the following:
# - Double-quoted text:  <tt>"foo"</tt>.
# - Number:  +1+, +1.0+, +2.0e2+.
# - Boolean:  +true+, +false+.
# - Null: +null+.
# - \Array: an ordered list of values, enclosed by square brackets:
#     ["foo", 1, 1.0, 2.0e2, true, false, null]
#
# - \Object: a collection of name/value pairs, enclosed by curly braces;
#   each name is double-quoted text;
#   the values may be any \FunJSON values:
#     {"a": "foo", "b": 1, "c": 1.0, "d": 2.0e2, "e": true, "f": false, "g": null}
#
# A \FunJSON array or object may contain nested arrays, objects, and scalars
# to any depth:
#   {"foo": {"bar": 1, "baz": 2}, "bat": [0, 1, 2]}
#   [{"foo": 0, "bar": 1}, ["baz", 2]]
#
# == Using \Module \FunJSON
#
# To make module \FunJSON available in your code, begin with:
#   require 'fun_json'
#
# All examples here assume that this has been done.
#
# === Parsing \FunJSON
#
# You can parse a \String containing \FunJSON data using
# either of two methods:
# - <tt>FunJSON.parse(source, opts)</tt>
# - <tt>FunJSON.parse!(source, opts)</tt>
#
# where
# - +source+ is a Ruby object.
# - +opts+ is a \Hash object containing options
#   that control both input allowed and output formatting.
#
# The difference between the two methods
# is that FunJSON.parse! omits some checks
# and may not be safe for some +source+ data;
# use it only for data from trusted sources.
# Use the safer method FunJSON.parse for less trusted sources.
#
# ==== Parsing \FunJSON Arrays
#
# When +source+ is a \FunJSON array, FunJSON.parse by default returns a Ruby \Array:
#   json = '["foo", 1, 1.0, 2.0e2, true, false, null]'
#   ruby = FunJSON.parse(json)
#   ruby # => ["foo", 1, 1.0, 200.0, true, false, nil]
#   ruby.class # => Array
#
# The \FunJSON array may contain nested arrays, objects, and scalars
# to any depth:
#   json = '[{"foo": 0, "bar": 1}, ["baz", 2]]'
#   FunJSON.parse(json) # => [{"foo"=>0, "bar"=>1}, ["baz", 2]]
#
# ==== Parsing \FunJSON \Objects
#
# When the source is a \FunJSON object, FunJSON.parse by default returns a Ruby \Hash:
#   json = '{"a": "foo", "b": 1, "c": 1.0, "d": 2.0e2, "e": true, "f": false, "g": null}'
#   ruby = FunJSON.parse(json)
#   ruby # => {"a"=>"foo", "b"=>1, "c"=>1.0, "d"=>200.0, "e"=>true, "f"=>false, "g"=>nil}
#   ruby.class # => Hash
#
# The \FunJSON object may contain nested arrays, objects, and scalars
# to any depth:
#   json = '{"foo": {"bar": 1, "baz": 2}, "bat": [0, 1, 2]}'
#   FunJSON.parse(json) # => {"foo"=>{"bar"=>1, "baz"=>2}, "bat"=>[0, 1, 2]}
#
# ==== Parsing \FunJSON Scalars
#
# When the source is a \FunJSON scalar (not an array or object),
# FunJSON.parse returns a Ruby scalar.
#
# \String:
#   ruby = FunJSON.parse('"foo"')
#   ruby # => 'foo'
#   ruby.class # => String
# \Integer:
#   ruby = FunJSON.parse('1')
#   ruby # => 1
#   ruby.class # => Integer
# \Float:
#   ruby = FunJSON.parse('1.0')
#   ruby # => 1.0
#   ruby.class # => Float
#   ruby = FunJSON.parse('2.0e2')
#   ruby # => 200
#   ruby.class # => Float
# Boolean:
#   ruby = FunJSON.parse('true')
#   ruby # => true
#   ruby.class # => TrueClass
#   ruby = FunJSON.parse('false')
#   ruby # => false
#   ruby.class # => FalseClass
# Null:
#   ruby = FunJSON.parse('null')
#   ruby # => nil
#   ruby.class # => NilClass
#
# ==== Parsing Options
#
# ====== Input Options
#
# Option +max_nesting+ (\Integer) specifies the maximum nesting depth allowed;
# defaults to +100+; specify +false+ to disable depth checking.
#
# With the default, +false+:
#   source = '[0, [1, [2, [3]]]]'
#   ruby = FunJSON.parse(source)
#   ruby # => [0, [1, [2, [3]]]]
# Too deep:
#   # Raises FunJSON::NestingError (nesting of 2 is too deep):
#   FunJSON.parse(source, {max_nesting: 1})
# Bad value:
#   # Raises TypeError (wrong argument type Symbol (expected Fixnum)):
#   FunJSON.parse(source, {max_nesting: :foo})
#
# ---
#
# Option +allow_nan+ (boolean) specifies whether to allow
# NaN, Infinity, and MinusInfinity in +source+;
# defaults to +false+.
#
# With the default, +false+:
#   # Raises FunJSON::ParserError (225: unexpected token at '[NaN]'):
#   FunJSON.parse('[NaN]')
#   # Raises FunJSON::ParserError (232: unexpected token at '[Infinity]'):
#   FunJSON.parse('[Infinity]')
#   # Raises FunJSON::ParserError (248: unexpected token at '[-Infinity]'):
#   FunJSON.parse('[-Infinity]')
# Allow:
#   source = '[NaN, Infinity, -Infinity]'
#   ruby = FunJSON.parse(source, {allow_nan: true})
#   ruby # => [NaN, Infinity, -Infinity]
#
# ====== Output Options
#
# Option +symbolize_names+ (boolean) specifies whether returned \Hash keys
# should be Symbols;
# defaults to +false+ (use Strings).
#
# With the default, +false+:
#   source = '{"a": "foo", "b": 1.0, "c": true, "d": false, "e": null}'
#   ruby = FunJSON.parse(source)
#   ruby # => {"a"=>"foo", "b"=>1.0, "c"=>true, "d"=>false, "e"=>nil}
# Use Symbols:
#   ruby = FunJSON.parse(source, {symbolize_names: true})
#   ruby # => {:a=>"foo", :b=>1.0, :c=>true, :d=>false, :e=>nil}
#
# ---
#
# Option +object_class+ (\Class) specifies the Ruby class to be used
# for each \FunJSON object;
# defaults to \Hash.
#
# With the default, \Hash:
#   source = '{"a": "foo", "b": 1.0, "c": true, "d": false, "e": null}'
#   ruby = FunJSON.parse(source)
#   ruby.class # => Hash
# Use class \OpenStruct:
#   ruby = FunJSON.parse(source, {object_class: OpenStruct})
#   ruby # => #<OpenStruct a="foo", b=1.0, c=true, d=false, e=nil>
#
# ---
#
# Option +array_class+ (\Class) specifies the Ruby class to be used
# for each \FunJSON array;
# defaults to \Array.
#
# With the default, \Array:
#   source = '["foo", 1.0, true, false, null]'
#   ruby = FunJSON.parse(source)
#   ruby.class # => Array
# Use class \Set:
#   ruby = FunJSON.parse(source, {array_class: Set})
#   ruby # => #<Set: {"foo", 1.0, true, false, nil}>
#
# ---
#
# Option +create_additions+ (boolean) specifies whether to use \FunJSON additions in parsing.
# See {\FunJSON Additions}[#module-FunJSON-label-FunJSON+Additions].
#
# === Generating \FunJSON
#
# To generate a Ruby \String containing \FunJSON data,
# use method <tt>FunJSON.generate(source, opts)</tt>, where
# - +source+ is a Ruby object.
# - +opts+ is a \Hash object containing options
#   that control both input allowed and output formatting.
#
# ==== Generating \FunJSON from Arrays
#
# When the source is a Ruby \Array, FunJSON.generate returns
# a \String containing a \FunJSON array:
#   ruby = [0, 's', :foo]
#   json = FunJSON.generate(ruby)
#   json # => '[0,"s","foo"]'
#
# The Ruby \Array array may contain nested arrays, hashes, and scalars
# to any depth:
#   ruby = [0, [1, 2], {foo: 3, bar: 4}]
#   json = FunJSON.generate(ruby)
#   json # => '[0,[1,2],{"foo":3,"bar":4}]'
#
# ==== Generating \FunJSON from Hashes
#
# When the source is a Ruby \Hash, FunJSON.generate returns
# a \String containing a \FunJSON object:
#   ruby = {foo: 0, bar: 's', baz: :bat}
#   json = FunJSON.generate(ruby)
#   json # => '{"foo":0,"bar":"s","baz":"bat"}'
#
# The Ruby \Hash array may contain nested arrays, hashes, and scalars
# to any depth:
#   ruby = {foo: [0, 1], bar: {baz: 2, bat: 3}, bam: :bad}
#   json = FunJSON.generate(ruby)
#   json # => '{"foo":[0,1],"bar":{"baz":2,"bat":3},"bam":"bad"}'
#
# ==== Generating \FunJSON from Other Objects
#
# When the source is neither an \Array nor a \Hash,
# the generated \FunJSON data depends on the class of the source.
#
# When the source is a Ruby \Integer or \Float, FunJSON.generate returns
# a \String containing a \FunJSON number:
#   FunJSON.generate(42) # => '42'
#   FunJSON.generate(0.42) # => '0.42'
#
# When the source is a Ruby \String, FunJSON.generate returns
# a \String containing a \FunJSON string (with double-quotes):
#   FunJSON.generate('A string') # => '"A string"'
#
# When the source is +true+, +false+ or +nil+, FunJSON.generate returns
# a \String containing the corresponding \FunJSON token:
#   FunJSON.generate(true) # => 'true'
#   FunJSON.generate(false) # => 'false'
#   FunJSON.generate(nil) # => 'null'
#
# When the source is none of the above, FunJSON.generate returns
# a \String containing a \FunJSON string representation of the source:
#   FunJSON.generate(:foo) # => '"foo"'
#   FunJSON.generate(Complex(0, 0)) # => '"0+0i"'
#   FunJSON.generate(Dir.new('.')) # => '"#<Dir>"'
#
# ==== Generating Options
#
# ====== Input Options
#
# Option +allow_nan+ (boolean) specifies whether
# +NaN+, +Infinity+, and <tt>-Infinity</tt> may be generated;
# defaults to +false+.
#
# With the default, +false+:
#   # Raises FunJSON::GeneratorError (920: NaN not allowed in FunJSON):
#   FunJSON.generate(FunJSON::NaN)
#   # Raises FunJSON::GeneratorError (917: Infinity not allowed in FunJSON):
#   FunJSON.generate(FunJSON::Infinity)
#   # Raises FunJSON::GeneratorError (917: -Infinity not allowed in FunJSON):
#   FunJSON.generate(FunJSON::MinusInfinity)
#
# Allow:
#   ruby = [Float::NaN, Float::Infinity, Float::MinusInfinity]
#   FunJSON.generate(ruby, allow_nan: true) # => '[NaN,Infinity,-Infinity]'
#
# ---
#
# Option +max_nesting+ (\Integer) specifies the maximum nesting depth
# in +obj+; defaults to +100+.
#
# With the default, +100+:
#   obj = [[[[[[0]]]]]]
#   FunJSON.generate(obj) # => '[[[[[[0]]]]]]'
#
# Too deep:
#   # Raises FunJSON::NestingError (nesting of 2 is too deep):
#   FunJSON.generate(obj, max_nesting: 2)
#
# ====== Output Options
#
# The default formatting options generate the most compact
# \FunJSON data, all on one line and with no whitespace.
#
# You can use these formatting options to generate
# \FunJSON data in a more open format, using whitespace.
# See also FunJSON.pretty_generate.
#
# - Option +array_nl+ (\String) specifies a string (usually a newline)
#   to be inserted after each \FunJSON array; defaults to the empty \String, <tt>''</tt>.
# - Option +object_nl+ (\String) specifies a string (usually a newline)
#   to be inserted after each \FunJSON object; defaults to the empty \String, <tt>''</tt>.
# - Option +indent+ (\String) specifies the string (usually spaces) to be
#   used for indentation; defaults to the empty \String, <tt>''</tt>;
#   defaults to the empty \String, <tt>''</tt>;
#   has no effect unless options +array_nl+ or +object_nl+ specify newlines.
# - Option +space+ (\String) specifies a string (usually a space) to be
#   inserted after the colon in each \FunJSON object's pair;
#   defaults to the empty \String, <tt>''</tt>.
# - Option +space_before+ (\String) specifies a string (usually a space) to be
#   inserted before the colon in each \FunJSON object's pair;
#   defaults to the empty \String, <tt>''</tt>.
#
# In this example, +obj+ is used first to generate the shortest
# \FunJSON data (no whitespace), then again with all formatting options
# specified:
#
#   obj = {foo: [:bar, :baz], bat: {bam: 0, bad: 1}}
#   json = FunJSON.generate(obj)
#   puts 'Compact:', json
#   opts = {
#     array_nl: "\n",
#     object_nl: "\n",
#     indent: '  ',
#     space_before: ' ',
#     space: ' '
#   }
#   puts 'Open:', FunJSON.generate(obj, opts)
#
# Output:
#   Compact:
#   {"foo":["bar","baz"],"bat":{"bam":0,"bad":1}}
#   Open:
#   {
#     "foo" : [
#       "bar",
#       "baz"
#   ],
#     "bat" : {
#       "bam" : 0,
#       "bad" : 1
#     }
#   }
#
# == \FunJSON Additions
#
# When you "round trip" a non-\String object from Ruby to \FunJSON and back,
# you have a new \String, instead of the object you began with:
#   ruby0 = Range.new(0, 2)
#   json = FunJSON.generate(ruby0)
#   json # => '0..2"'
#   ruby1 = FunJSON.parse(json)
#   ruby1 # => '0..2'
#   ruby1.class # => String
#
# You can use \FunJSON _additions_ to preserve the original object.
# The addition is an extension of a ruby class, so that:
# - \FunJSON.generate stores more information in the \FunJSON string.
# - \FunJSON.parse, called with option +create_additions+,
#   uses that information to create a proper Ruby object.
#
# This example shows a \Range being generated into \FunJSON
# and parsed back into Ruby, both without and with
# the addition for \Range:
#   ruby = Range.new(0, 2)
#   # This passage does not use the addition for Range.
#   json0 = FunJSON.generate(ruby)
#   ruby0 = FunJSON.parse(json0)
#   # This passage uses the addition for Range.
#   require 'fun_json/add/range'
#   json1 = FunJSON.generate(ruby)
#   ruby1 = FunJSON.parse(json1, create_additions: true)
#   # Make a nice display.
#   display = <<EOT
#   Generated FunJSON:
#     Without addition:  #{json0} (#{json0.class})
#     With addition:     #{json1} (#{json1.class})
#   Parsed FunJSON:
#     Without addition:  #{ruby0.inspect} (#{ruby0.class})
#     With addition:     #{ruby1.inspect} (#{ruby1.class})
#   EOT
#   puts display
#
# This output shows the different results:
#   Generated FunJSON:
#     Without addition:  "0..2" (String)
#     With addition:     {"json_class":"Range","a":[0,2,false]} (String)
#   Parsed FunJSON:
#     Without addition:  "0..2" (String)
#     With addition:     0..2 (Range)
#
# The \FunJSON module includes additions for certain classes.
# You can also craft custom additions.
# See {Custom \FunJSON Additions}[#module-FunJSON-label-Custom+FunJSON+Additions].
#
# === Built-in Additions
#
# The \FunJSON module includes additions for certain classes.
# To use an addition, +require+ its source:
# - BigDecimal: <tt>require 'fun_json/add/bigdecimal'</tt>
# - Complex: <tt>require 'fun_json/add/complex'</tt>
# - Date: <tt>require 'fun_json/add/date'</tt>
# - DateTime: <tt>require 'fun_json/add/date_time'</tt>
# - Exception: <tt>require 'fun_json/add/exception'</tt>
# - OpenStruct: <tt>require 'fun_json/add/ostruct'</tt>
# - Range: <tt>require 'fun_json/add/range'</tt>
# - Rational: <tt>require 'fun_json/add/rational'</tt>
# - Regexp: <tt>require 'fun_json/add/regexp'</tt>
# - Set: <tt>require 'fun_json/add/set'</tt>
# - Struct: <tt>require 'fun_json/add/struct'</tt>
# - Symbol: <tt>require 'fun_json/add/symbol'</tt>
# - Time: <tt>require 'fun_json/add/time'</tt>
#
# To reduce punctuation clutter, the examples below
# show the generated \FunJSON via +puts+, rather than the usual +inspect+,
#
# \BigDecimal:
#   require 'fun_json/add/bigdecimal'
#   ruby0 = BigDecimal(0) # 0.0
#   json = FunJSON.generate(ruby0) # {"json_class":"BigDecimal","b":"27:0.0"}
#   ruby1 = FunJSON.parse(json, create_additions: true) # 0.0
#   ruby1.class # => BigDecimal
#
# \Complex:
#   require 'fun_json/add/complex'
#   ruby0 = Complex(1+0i) # 1+0i
#   json = FunJSON.generate(ruby0) # {"json_class":"Complex","r":1,"i":0}
#   ruby1 = FunJSON.parse(json, create_additions: true) # 1+0i
#   ruby1.class # Complex
#
# \Date:
#   require 'fun_json/add/date'
#   ruby0 = Date.today # 2020-05-02
#   json = FunJSON.generate(ruby0) # {"json_class":"Date","y":2020,"m":5,"d":2,"sg":2299161.0}
#   ruby1 = FunJSON.parse(json, create_additions: true) # 2020-05-02
#   ruby1.class # Date
#
# \DateTime:
#   require 'fun_json/add/date_time'
#   ruby0 = DateTime.now # 2020-05-02T10:38:13-05:00
#   json = FunJSON.generate(ruby0) # {"json_class":"DateTime","y":2020,"m":5,"d":2,"H":10,"M":38,"S":13,"of":"-5/24","sg":2299161.0}
#   ruby1 = FunJSON.parse(json, create_additions: true) # 2020-05-02T10:38:13-05:00
#   ruby1.class # DateTime
#
# \Exception (and its subclasses including \RuntimeError):
#   require 'fun_json/add/exception'
#   ruby0 = Exception.new('A message') # A message
#   json = FunJSON.generate(ruby0) # {"json_class":"Exception","m":"A message","b":null}
#   ruby1 = FunJSON.parse(json, create_additions: true) # A message
#   ruby1.class # Exception
#   ruby0 = RuntimeError.new('Another message') # Another message
#   json = FunJSON.generate(ruby0) # {"json_class":"RuntimeError","m":"Another message","b":null}
#   ruby1 = FunJSON.parse(json, create_additions: true) # Another message
#   ruby1.class # RuntimeError
#
# \OpenStruct:
#   require 'fun_json/add/ostruct'
#   ruby0 = OpenStruct.new(name: 'Matz', language: 'Ruby') # #<OpenStruct name="Matz", language="Ruby">
#   json = FunJSON.generate(ruby0) # {"json_class":"OpenStruct","t":{"name":"Matz","language":"Ruby"}}
#   ruby1 = FunJSON.parse(json, create_additions: true) # #<OpenStruct name="Matz", language="Ruby">
#   ruby1.class # OpenStruct
#
# \Range:
#   require 'fun_json/add/range'
#   ruby0 = Range.new(0, 2) # 0..2
#   json = FunJSON.generate(ruby0) # {"json_class":"Range","a":[0,2,false]}
#   ruby1 = FunJSON.parse(json, create_additions: true) # 0..2
#   ruby1.class # Range
#
# \Rational:
#   require 'fun_json/add/rational'
#   ruby0 = Rational(1, 3) # 1/3
#   json = FunJSON.generate(ruby0) # {"json_class":"Rational","n":1,"d":3}
#   ruby1 = FunJSON.parse(json, create_additions: true) # 1/3
#   ruby1.class # Rational
#
# \Regexp:
#   require 'fun_json/add/regexp'
#   ruby0 = Regexp.new('foo') # (?-mix:foo)
#   json = FunJSON.generate(ruby0) # {"json_class":"Regexp","o":0,"s":"foo"}
#   ruby1 = FunJSON.parse(json, create_additions: true) # (?-mix:foo)
#   ruby1.class # Regexp
#
# \Set:
#   require 'fun_json/add/set'
#   ruby0 = Set.new([0, 1, 2]) # #<Set: {0, 1, 2}>
#   json = FunJSON.generate(ruby0) # {"json_class":"Set","a":[0,1,2]}
#   ruby1 = FunJSON.parse(json, create_additions: true) # #<Set: {0, 1, 2}>
#   ruby1.class # Set
#
# \Struct:
#   require 'fun_json/add/struct'
#   Customer = Struct.new(:name, :address) # Customer
#   ruby0 = Customer.new("Dave", "123 Main") # #<struct Customer name="Dave", address="123 Main">
#   json = FunJSON.generate(ruby0) # {"json_class":"Customer","v":["Dave","123 Main"]}
#   ruby1 = FunJSON.parse(json, create_additions: true) # #<struct Customer name="Dave", address="123 Main">
#   ruby1.class # Customer
  #
# \Symbol:
#   require 'fun_json/add/symbol'
#   ruby0 = :foo # foo
#   json = FunJSON.generate(ruby0) # {"json_class":"Symbol","s":"foo"}
#   ruby1 = FunJSON.parse(json, create_additions: true) # foo
#   ruby1.class # Symbol
#
# \Time:
#   require 'fun_json/add/time'
#   ruby0 = Time.now # 2020-05-02 11:28:26 -0500
#   json = FunJSON.generate(ruby0) # {"json_class":"Time","s":1588436906,"n":840560000}
#   ruby1 = FunJSON.parse(json, create_additions: true) # 2020-05-02 11:28:26 -0500
#   ruby1.class # Time
#
#
# === Custom \FunJSON Additions
#
# In addition to the \FunJSON additions provided,
# you can craft \FunJSON additions of your own,
# either for Ruby built-in classes or for user-defined classes.
#
# Here's a user-defined class +Foo+:
#   class Foo
#     attr_accessor :bar, :baz
#     def initialize(bar, baz)
#       self.bar = bar
#       self.baz = baz
#     end
#   end
#
# Here's the \FunJSON addition for it:
#   # Extend class Foo with FunJSON addition.
#   class Foo
#     # Serialize Foo object with its class name and arguments
#     def to_fun_json(*args)
#       {
#         FunJSON.create_id  => self.class.name,
#         'a'             => [ bar, baz ]
#       }.to_fun_json(*args)
#     end
#     # Deserialize FunJSON string by constructing new Foo object with arguments.
#     def self.json_create(object)
#       new(*object['a'])
#     end
#   end
#
# Demonstration:
#   require 'fun_json'
#   # This Foo object has no custom addition.
#   foo0 = Foo.new(0, 1)
#   json0 = FunJSON.generate(foo0)
#   obj0 = FunJSON.parse(json0)
#   # Lood the custom addition.
#   require_relative 'foo_addition'
#   # This foo has the custom addition.
#   foo1 = Foo.new(0, 1)
#   json1 = FunJSON.generate(foo1)
#   obj1 = FunJSON.parse(json1, create_additions: true)
#   #   Make a nice display.
#   display = <<EOT
#   Generated FunJSON:
#     Without custom addition:  #{json0} (#{json0.class})
#     With custom addition:     #{json1} (#{json1.class})
#   Parsed FunJSON:
#     Without custom addition:  #{obj0.inspect} (#{obj0.class})
#     With custom addition:     #{obj1.inspect} (#{obj1.class})
#   EOT
#   puts display
#
# Output:
#
#   Generated FunJSON:
#     Without custom addition:  "#<Foo:0x0000000006534e80>" (String)
#     With custom addition:     {"json_class":"Foo","a":[0,1]} (String)
#   Parsed FunJSON:
#     Without custom addition:  "#<Foo:0x0000000006534e80>" (String)
#     With custom addition:     #<Foo:0x0000000006473bb8 @bar=0, @baz=1> (Foo)
#
module FunJSON
  require 'fun_json/version'
  require 'fun_json/pure'
end
