#frozen_string_literal: false
require 'fun_json/version'
require 'fun_json/generic_object'

module FunJSON
  class << self
    # :call-seq:
    #   FunJSON[object] -> new_array or new_string
    #
    # If +object+ is a
    # {String-convertible object}[doc/implicit_conversion_rdoc.html#label-String-Convertible+Objects],
    # calls FunJSON.parse with +object+ and +opts+ (see method #parse):
    #   json = '[0, 1, null]'
    #   FunJSON[json]# => [0, 1, nil]
    #
    # Otherwise, calls FunJSON.generate with +object+ and +opts+ (see method #generate):
    #   ruby = [0, 1, nil]
    #   FunJSON[ruby] # => '[0,1,null]'
    def [](object, opts = {})
      if object.respond_to? :to_str
        FunJSON.parse(object.to_str, opts)
      else
        FunJSON.generate(object, opts)
      end
    end

    # Returns the FunJSON parser class that is used by FunJSON. This is either
    # FunJSON::Ext::Parser or FunJSON::Pure::Parser:
    #   FunJSON.parser # => FunJSON::Ext::Parser
    attr_reader :parser

    # Set the FunJSON parser class _parser_ to be used by FunJSON.
    def parser=(parser) # :nodoc:
      @parser = parser
      remove_const :Parser if const_defined?(:Parser, false)
      const_set :Parser, parser
    end

    # Return the constant located at _path_. The format of _path_ has to be
    # either ::A::B::C or A::B::C. In any case, A has to be located at the top
    # level (absolute namespace path?). If there doesn't exist a constant at
    # the given path, an ArgumentError is raised.
    def deep_const_get(path) # :nodoc:
      path.to_s.split(/::/).inject(Object) do |p, c|
        case
        when c.empty?                  then p
        when p.const_defined?(c, true) then p.const_get(c)
        else
          begin
            p.const_missing(c)
          rescue NameError => e
            raise ArgumentError, "can't get const #{path}: #{e}"
          end
        end
      end
    end

    # Set the module _generator_ to be used by FunJSON.
    def generator=(generator) # :nodoc:
      old, $VERBOSE = $VERBOSE, nil
      @generator = generator
      generator_methods = generator::GeneratorMethods
      for const in generator_methods.constants
        klass = deep_const_get(const)
        modul = generator_methods.const_get(const)
        klass.class_eval do
          instance_methods(false).each do |m|
            m.to_s == 'to_fun_json' and remove_method m
          end
          include modul
        end
      end
      self.state = generator::State
      const_set :State, self.state
      const_set :SAFE_STATE_PROTOTYPE, State.new
      const_set :FAST_STATE_PROTOTYPE, State.new(
        :indent         => '',
        :space          => '',
        :object_nl      => "",
        :array_nl       => "",
        :max_nesting    => false
      )
      const_set :PRETTY_STATE_PROTOTYPE, State.new(
        :indent         => '  ',
        :space          => ' ',
        :object_nl      => "\n",
        :array_nl       => "\n"
      )
    ensure
      $VERBOSE = old
    end

    # Returns the FunJSON generator module that is used by FunJSON. This is
    # either FunJSON::Ext::Generator or FunJSON::Pure::Generator:
    #   FunJSON.generator # => FunJSON::Ext::Generator
    attr_reader :generator

    # Sets or Returns the FunJSON generator state class that is used by FunJSON. This is
    # either FunJSON::Ext::Generator::State or FunJSON::Pure::Generator::State:
    #   FunJSON.state # => FunJSON::Ext::Generator::State
    attr_accessor :state

    # Sets or returns create identifier, which is used to decide if the _json_create_
    # hook of a class should be called; initial value is +json_class+:
    #   FunJSON.create_id # => 'json_class'
    attr_accessor :create_id
  end
  self.create_id = 'json_class'

  NaN           = 0.0/0

  Infinity      = 1.0/0

  MinusInfinity = -Infinity

  # The base exception for FunJSON errors.
  class JSONError < StandardError
    def self.wrap(exception)
      obj = new("Wrapped(#{exception.class}): #{exception.message.inspect}")
      obj.set_backtrace exception.backtrace
      obj
    end
  end

  # This exception is raised if a parser error occurs.
  class ParserError < JSONError; end

  # This exception is raised if the nesting of parsed data structures is too
  # deep.
  class NestingError < ParserError; end

  # :stopdoc:
  class CircularDatastructure < NestingError; end
  # :startdoc:

  # This exception is raised if a generator or unparser error occurs.
  class GeneratorError < JSONError; end
  # For backwards compatibility
  UnparserError = GeneratorError # :nodoc:

  # This exception is raised if the required unicode support is missing on the
  # system. Usually this means that the iconv library is not installed.
  class MissingUnicodeSupport < JSONError; end

  module_function

  # :call-seq:
  #   FunJSON.parse(source, opts) -> object
  #
  # Returns the Ruby objects created by parsing the given +source+.
  #
  # Argument +source+ contains the \String to be parsed. It must be a
  # {String-convertible object}[doc/implicit_conversion_rdoc.html#label-String-Convertible+Objects]
  # (implementing +to_str+), and must contain valid \FunJSON data.
  #
  # Argument +opts+, if given, contains options for the parsing, and must be a
  # {Hash-convertible object}[doc/implicit_conversion_rdoc.html#label-Hash+Convertible+Objects].
  # See {Parsing Options}[#module-FunJSON-label-Parsing+Options].
  #
  # ---
  #
  # When +source+ is a \FunJSON array, returns a Ruby \Array:
  #   source = '["foo", 1.0, true, false, null]'
  #   ruby = FunJSON.parse(source)
  #   ruby # => ["foo", 1.0, true, false, nil]
  #   ruby.class # => Array
  #
  # When +source+ is a \FunJSON object, returns a Ruby \Hash:
  #   source = '{"a": "foo", "b": 1.0, "c": true, "d": false, "e": null}'
  #   ruby = FunJSON.parse(source)
  #   ruby # => {"a"=>"foo", "b"=>1.0, "c"=>true, "d"=>false, "e"=>nil}
  #   ruby.class # => Hash
  #
  # For examples of parsing for all \FunJSON data types, see
  # {Parsing \FunJSON}[#module-FunJSON-label-Parsing+FunJSON].
  #
  # Parses nested FunJSON objects:
  #   source = <<-EOT
  #   {
  #   "name": "Dave",
  #     "age" :40,
  #     "hats": [
  #       "Cattleman's",
  #       "Panama",
  #       "Tophat"
  #     ]
  #   }
  #   EOT
  #   ruby = FunJSON.parse(source)
  #   ruby # => {"name"=>"Dave", "age"=>40, "hats"=>["Cattleman's", "Panama", "Tophat"]}
  #
  # ---
  #
  # Raises an exception if +source+ is not valid FunJSON:
  #   # Raises FunJSON::ParserError (783: unexpected token at ''):
  #   FunJSON.parse('')
  #
  def parse(source, opts = {})
    Parser.new(source, **(opts||{})).parse
  end

  # :call-seq:
  #   FunJSON.parse!(source, opts) -> object
  #
  # Calls
  #   parse(source, opts)
  # with +source+ and possibly modified +opts+.
  #
  # Differences from FunJSON.parse:
  # - Option +max_nesting+, if not provided, defaults to +false+,
  #   which disables checking for nesting depth.
  # - Option +allow_nan+, if not provided, defaults to +true+.
  def parse!(source, opts = {})
    opts = {
      :max_nesting  => false,
      :allow_nan    => true
    }.merge(opts)
    Parser.new(source, **(opts||{})).parse
  end

  # :call-seq:
  #   CSV.load_file(path, opts={}) -> object
  #
  # Calls:
  #   parse(File.read(path), opts)
  #
  # See method #parse.
  def load_file(filespec, opts = {})
    parse(File.read(filespec), opts)
  end

  # :call-seq:
  #   CSV.load_file!(path, opts = {})
  #
  # Calls:
  #   CSV.parse!(File.read(path, opts))
  #
  # See method #parse!
  def load_file!(filespec, opts = {})
    parse!(File.read(filespec), opts)
  end

  # :call-seq:
  #   FunJSON.generate(obj, opts = nil) -> new_string
  #
  # Returns a \String containing the generated \FunJSON data.
  #
  # See also FunJSON.fast_generate, FunJSON.pretty_generate.
  #
  # Argument +obj+ is the Ruby object to be converted to \FunJSON.
  #
  # Argument +opts+, if given, contains options for the generation, and must be a
  # {Hash-convertible object}[doc/implicit_conversion_rdoc.html#label-Hash-Convertible+Objects].
  # See {Generating Options}[#module-FunJSON-label-Generating+Options].
  #
  # ---
  #
  # When +obj+ is an
  # {Array-convertible object}[doc/implicit_conversion_rdoc.html#label-Array-Convertible+Objects]
  # (implementing +to_ary+), returns a \String containing a \FunJSON array:
  #   obj = ["foo", 1.0, true, false, nil]
  #   json = FunJSON.generate(obj)
  #   json # => '["foo",1.0,true,false,null]'
  #
  # When +obj+ is a
  # {Hash-convertible object}[doc/implicit_conversion_rdoc.html#label-Hash-Convertible+Objects],
  # return a \String containing a \FunJSON object:
  #   obj = {foo: 0, bar: 's', baz: :bat}
  #   json = FunJSON.generate(obj)
  #   json # => '{"foo":0,"bar":"s","baz":"bat"}'
  #
  # For examples of generating from other Ruby objects, see
  # {Generating \FunJSON from Other Objects}[#module-FunJSON-label-Generating+FunJSON+from+Other+Objects].
  #
  # ---
  #
  # Raises an exception if any formatting option is not a \String.
  #
  # Raises an exception if +obj+ contains circular references:
  #   a = []; b = []; a.push(b); b.push(a)
  #   # Raises FunJSON::NestingError (nesting of 100 is too deep):
  #   FunJSON.generate(a)
  #
  def generate(obj, opts = nil)
    if State === opts
      state, opts = opts, nil
    else
      state = SAFE_STATE_PROTOTYPE.dup
    end
    if opts
      if opts.respond_to? :to_hash
        opts = opts.to_hash
      elsif opts.respond_to? :to_h
        opts = opts.to_h
      else
        raise TypeError, "can't convert #{opts.class} into Hash"
      end
      state = state.configure(opts)
    end
    state.generate(obj)
  end

  # :stopdoc:
  # I want to deprecate these later, so I'll first be silent about them, and
  # later delete them.
  alias unparse generate
  module_function :unparse
  # :startdoc:

  # :call-seq:
  #   FunJSON.fast_generate(obj, opts) -> new_string
  #
  # Arguments +obj+ and +opts+ here are the same as
  # arguments +obj+ and +opts+ in FunJSON.generate.
  #
  # By default, generates \FunJSON data without checking
  # for circular references in +obj+ (option +max_nesting+ set to +false+, disabled).
  #
  # Raises an exception if +obj+ contains circular references:
  #   a = []; b = []; a.push(b); b.push(a)
  #   # Raises SystemStackError (stack level too deep):
  #   FunJSON.fast_generate(a)
  def fast_generate(obj, opts = nil)
    if State === opts
      state, opts = opts, nil
    else
      state = FAST_STATE_PROTOTYPE.dup
    end
    if opts
      if opts.respond_to? :to_hash
        opts = opts.to_hash
      elsif opts.respond_to? :to_h
        opts = opts.to_h
      else
        raise TypeError, "can't convert #{opts.class} into Hash"
      end
      state.configure(opts)
    end
    state.generate(obj)
  end

  # :stopdoc:
  # I want to deprecate these later, so I'll first be silent about them, and later delete them.
  alias fast_unparse fast_generate
  module_function :fast_unparse
  # :startdoc:

  # :call-seq:
  #   FunJSON.pretty_generate(obj, opts = nil) -> new_string
  #
  # Arguments +obj+ and +opts+ here are the same as
  # arguments +obj+ and +opts+ in FunJSON.generate.
  #
  # Default options are:
  #   {
  #     indent: '  ',   # Two spaces
  #     space: ' ',     # One space
  #     array_nl: "\n", # Newline
  #     object_nl: "\n" # Newline
  #   }
  #
  # Example:
  #   obj = {foo: [:bar, :baz], bat: {bam: 0, bad: 1}}
  #   json = FunJSON.pretty_generate(obj)
  #   puts json
  # Output:
  #   {
  #     "foo": [
  #       "bar",
  #       "baz"
  #     ],
  #     "bat": {
  #       "bam": 0,
  #       "bad": 1
  #     }
  #   }
  #
  def pretty_generate(obj, opts = nil)
    if State === opts
      state, opts = opts, nil
    else
      state = PRETTY_STATE_PROTOTYPE.dup
    end
    if opts
      if opts.respond_to? :to_hash
        opts = opts.to_hash
      elsif opts.respond_to? :to_h
        opts = opts.to_h
      else
        raise TypeError, "can't convert #{opts.class} into Hash"
      end
      state.configure(opts)
    end
    state.generate(obj)
  end

  # :stopdoc:
  # I want to deprecate these later, so I'll first be silent about them, and later delete them.
  alias pretty_unparse pretty_generate
  module_function :pretty_unparse
  # :startdoc:

  class << self
    # Sets or returns default options for the FunJSON.load method.
    # Initially:
    #   opts = FunJSON.load_default_options
    #   opts # => {:max_nesting=>false, :allow_nan=>true, :allow_blank=>true, :create_additions=>true}
    attr_accessor :load_default_options
  end
  self.load_default_options = {
    :max_nesting      => false,
    :allow_nan        => true,
    :allow_blank       => true,
    :create_additions => true,
  }

  # :call-seq:
  #   FunJSON.load(source, proc = nil, options = {}) -> object
  #
  # Returns the Ruby objects created by parsing the given +source+.
  #
  # - Argument +source+ must be, or be convertible to, a \String:
  #   - If +source+ responds to instance method +to_str+,
  #     <tt>source.to_str</tt> becomes the source.
  #   - If +source+ responds to instance method +to_io+,
  #     <tt>source.to_io.read</tt> becomes the source.
  #   - If +source+ responds to instance method +read+,
  #     <tt>source.read</tt> becomes the source.
  #   - If both of the following are true, source becomes the \String <tt>'null'</tt>:
  #     - Option +allow_blank+ specifies a truthy value.
  #     - The source, as defined above, is +nil+ or the empty \String <tt>''</tt>.
  #   - Otherwise, +source+ remains the source.
  # - Argument +proc+, if given, must be a \Proc that accepts one argument.
  #   It will be called recursively with each result (depth-first order).
  #   See details below.
  #   BEWARE: This method is meant to serialise data from trusted user input,
  #   like from your own database server or clients under your control, it could
  #   be dangerous to allow untrusted users to pass FunJSON sources into it.
  # - Argument +opts+, if given, contains options for the parsing, and must be a
  #   {Hash-convertible object}[doc/implicit_conversion_rdoc.html#label-Hash+Convertible+Objects].
  #   See {Parsing Options}[#module-FunJSON-label-Parsing+Options].
  #   The default options can be changed via method FunJSON.load_default_options=.
  #
  # ---
  #
  # When no +proc+ is given, modifies +source+ as above and returns the result of
  # <tt>parse(source, opts)</tt>;  see #parse.
  #
  # Source for following examples:
  #   source = <<-EOT
  #   {
  #   "name": "Dave",
  #     "age" :40,
  #     "hats": [
  #       "Cattleman's",
  #       "Panama",
  #       "Tophat"
  #     ]
  #   }
  #   EOT
  #
  # Load a \String:
  #   ruby = FunJSON.load(source)
  #   ruby # => {"name"=>"Dave", "age"=>40, "hats"=>["Cattleman's", "Panama", "Tophat"]}
  #
  # Load an \IO object:
  #   require 'stringio'
  #   object = FunJSON.load(StringIO.new(source))
  #   object # => {"name"=>"Dave", "age"=>40, "hats"=>["Cattleman's", "Panama", "Tophat"]}
  #
  # Load a \File object:
  #   path = 't.json'
  #   File.write(path, source)
  #   File.open(path) do |file|
  #     FunJSON.load(file)
  #   end # => {"name"=>"Dave", "age"=>40, "hats"=>["Cattleman's", "Panama", "Tophat"]}
  #
  # ---
  #
  # When +proc+ is given:
  # - Modifies +source+ as above.
  # - Gets the +result+ from calling <tt>parse(source, opts)</tt>.
  # - Recursively calls <tt>proc(result)</tt>.
  # - Returns the final result.
  #
  # Example:
  #   require 'fun_json'
  #
  #   # Some classes for the example.
  #   class Base
  #     def initialize(attributes)
  #       @attributes = attributes
  #     end
  #   end
  #   class User    < Base; end
  #   class Account < Base; end
  #   class Admin   < Base; end
  #   # The FunJSON source.
  #   json = <<-EOF
  #   {
  #     "users": [
  #         {"type": "User", "username": "jane", "email": "jane@example.com"},
  #         {"type": "User", "username": "john", "email": "john@example.com"}
  #     ],
  #     "accounts": [
  #         {"account": {"type": "Account", "paid": true, "account_id": "1234"}},
  #         {"account": {"type": "Account", "paid": false, "account_id": "1235"}}
  #     ],
  #     "admins": {"type": "Admin", "password": "0wn3d"}
  #   }
  #   EOF
  #   # Deserializer method.
  #   def deserialize_obj(obj, safe_types = %w(User Account Admin))
  #     type = obj.is_a?(Hash) && obj["type"]
  #     safe_types.include?(type) ? Object.const_get(type).new(obj) : obj
  #   end
  #   # Call to FunJSON.load
  #   ruby = FunJSON.load(json, proc {|obj|
  #     case obj
  #     when Hash
  #       obj.each {|k, v| obj[k] = deserialize_obj v }
  #     when Array
  #       obj.map! {|v| deserialize_obj v }
  #     end
  #   })
  #   pp ruby
  # Output:
  #   {"users"=>
  #      [#<User:0x00000000064c4c98
  #        @attributes=
  #          {"type"=>"User", "username"=>"jane", "email"=>"jane@example.com"}>,
  #        #<User:0x00000000064c4bd0
  #        @attributes=
  #          {"type"=>"User", "username"=>"john", "email"=>"john@example.com"}>],
  #    "accounts"=>
  #      [{"account"=>
  #          #<Account:0x00000000064c4928
  #          @attributes={"type"=>"Account", "paid"=>true, "account_id"=>"1234"}>},
  #       {"account"=>
  #          #<Account:0x00000000064c4680
  #          @attributes={"type"=>"Account", "paid"=>false, "account_id"=>"1235"}>}],
  #    "admins"=>
  #      #<Admin:0x00000000064c41f8
  #      @attributes={"type"=>"Admin", "password"=>"0wn3d"}>}
  #
  def load(source, proc = nil, options = {})
    opts = load_default_options.merge options
    if source.respond_to? :to_str
      source = source.to_str
    elsif source.respond_to? :to_io
      source = source.to_io.read
    elsif source.respond_to?(:read)
      source = source.read
    end
    if opts[:allow_blank] && (source.nil? || source.empty?)
      source = 'null'
    end
    result = parse(source, opts)
    recurse_proc(result, &proc) if proc
    result
  end

  # Recursively calls passed _Proc_ if the parsed data structure is an _Array_ or _Hash_
  def recurse_proc(result, &proc) # :nodoc:
    case result
    when Array
      result.each { |x| recurse_proc x, &proc }
      proc.call result
    when Hash
      result.each { |x, y| recurse_proc x, &proc; recurse_proc y, &proc }
      proc.call result
    else
      proc.call result
    end
  end

  alias restore load
  module_function :restore

  class << self
    # Sets or returns the default options for the FunJSON.dump method.
    # Initially:
    #   opts = FunJSON.dump_default_options
    #   opts # => {:max_nesting=>false, :allow_nan=>true, :escape_slash=>false}
    attr_accessor :dump_default_options
  end
  self.dump_default_options = {
    :max_nesting => false,
    :allow_nan   => true,
    :escape_slash => false,
  }

  # :call-seq:
  #   FunJSON.dump(obj, io = nil, limit = nil)
  #
  # Dumps +obj+ as a \FunJSON string, i.e. calls generate on the object and returns the result.
  #
  # The default options can be changed via method FunJSON.dump_default_options.
  #
  # - Argument +io+, if given, should respond to method +write+;
  #   the \FunJSON \String is written to +io+, and +io+ is returned.
  #   If +io+ is not given, the \FunJSON \String is returned.
  # - Argument +limit+, if given, is passed to FunJSON.generate as option +max_nesting+.
  #
  # ---
  #
  # When argument +io+ is not given, returns the \FunJSON \String generated from +obj+:
  #   obj = {foo: [0, 1], bar: {baz: 2, bat: 3}, bam: :bad}
  #   json = FunJSON.dump(obj)
  #   json # => "{\"foo\":[0,1],\"bar\":{\"baz\":2,\"bat\":3},\"bam\":\"bad\"}"
  #
  # When argument +io+ is given, writes the \FunJSON \String to +io+ and returns +io+:
  #   path = 't.json'
  #   File.open(path, 'w') do |file|
  #     FunJSON.dump(obj, file)
  #   end # => #<File:t.json (closed)>
  #   puts File.read(path)
  # Output:
  #   {"foo":[0,1],"bar":{"baz":2,"bat":3},"bam":"bad"}
  def dump(obj, anIO = nil, limit = nil)
    if anIO and limit.nil?
      anIO = anIO.to_io if anIO.respond_to?(:to_io)
      unless anIO.respond_to?(:write)
        limit = anIO
        anIO = nil
      end
    end
    opts = FunJSON.dump_default_options
    opts = opts.merge(:max_nesting => limit) if limit
    result = generate(obj, opts)
    if anIO
      anIO.write result
      anIO
    else
      result
    end
  rescue FunJSON::NestingError
    raise ArgumentError, "exceed depth limit"
  end

  # Encodes string using String.encode.
  def self.iconv(to, from, string)
    string.encode(to, from)
  end
end

module ::Kernel
  private

  # Outputs _objs_ to STDOUT as FunJSON strings in the shortest form, that is in
  # one line.
  def j(*objs)
    objs.each do |obj|
      puts FunJSON::generate(obj, :allow_nan => true, :max_nesting => false)
    end
    nil
  end

  # Outputs _objs_ to STDOUT as FunJSON strings in a pretty format, with
  # indentation and over many lines.
  def jj(*objs)
    objs.each do |obj|
      puts FunJSON::pretty_generate(obj, :allow_nan => true, :max_nesting => false)
    end
    nil
  end

  # If _object_ is string-like, parse the string and return the parsed result as
  # a Ruby data structure. Otherwise, generate a FunJSON text from the Ruby data
  # structure object and return it.
  #
  # The _opts_ argument is passed through to generate/parse respectively. See
  # generate and parse for their documentation.
  def FunJSON(object, *args)
    if object.respond_to? :to_str
      FunJSON.parse(object.to_str, args.first)
    else
      FunJSON.generate(object, args.first)
    end
  end
end

# Extends any Class to include _json_creatable?_ method.
class ::Class
  # Returns true if this class can be used to create an instance
  # from a serialised FunJSON string. The class has to implement a class
  # method _json_create_ that expects a hash as first parameter. The hash
  # should include the required data.
  def json_creatable?
    respond_to?(:json_create)
  end
end
