# frozen_string_literal: true

require "erb"
require "set"
require "enumerator"
require "stringio"
require "rbconfig"
require "uri"
require "thread"
require "pathname"

# A module containing various useful functions.

module SassC::Util

  extend self

  # An array of ints representing the Ruby version number.
  # @api public
  RUBY_VERSION_COMPONENTS = RUBY_VERSION.split(".").map {|s| s.to_i}

  # The Ruby engine we're running under. Defaults to `"ruby"`
  # if the top-level constant is undefined.
  # @api public
  RUBY_ENGINE = defined?(::RUBY_ENGINE) ? ::RUBY_ENGINE : "ruby"

  # Returns the path of a file relative to the Sass root directory.
  # @param file [String] The filename relative to the Sass root
  # @return [String] The filename relative to the the working directory
  def scope(file)
    File.join(SassC::ROOT_DIR, file)
  end

  # Maps the keys in a hash according to a block.
  # @example
  #   map_keys({:foo => "bar", :baz => "bang"}) {|k| k.to_s}
  #     #=> {"foo" => "bar", "baz" => "bang"}
  # @param hash [Hash] The hash to map
  # @yield [key] A block in which the keys are transformed
  # @yieldparam key [Object] The key that should be mapped
  # @yieldreturn [Object] The new value for the key
  # @return [Hash] The mapped hash
  # @see #map_vals
  # @see #map_hash
  def map_keys(hash)
    map_hash(hash) {|k, v| [yield(k), v]}
  end

  # Maps the values in a hash according to a block.
  #
  # @example
  #   map_values({:foo => "bar", :baz => "bang"}) {|v| v.to_sym}
  #     #=> {:foo => :bar, :baz => :bang}
  # @param hash [Hash] The hash to map
  # @yield [value] A block in which the values are transformed
  # @yieldparam value [Object] The value that should be mapped
  # @yieldreturn [Object] The new value for the value
  # @return [Hash] The mapped hash
  # @see #map_keys
  # @see #map_hash
  def map_vals(hash)
    # We don't delegate to map_hash for performance here
    # because map_hash does more than is necessary.
    rv = hash.class.new
    hash = hash.as_stored if hash.is_a?(NormalizedMap)
    hash.each do |k, v|
      rv[k] = yield(v)
    end
    rv
  end

  # Maps the key-value pairs of a hash according to a block.
  #
  # @example
  #   map_hash({:foo => "bar", :baz => "bang"}) {|k, v| [k.to_s, v.to_sym]}
  #     #=> {"foo" => :bar, "baz" => :bang}
  # @param hash [Hash] The hash to map
  # @yield [key, value] A block in which the key-value pairs are transformed
  # @yieldparam [key] The hash key
  # @yieldparam [value] The hash value
  # @yieldreturn [(Object, Object)] The new value for the `[key, value]` pair
  # @return [Hash] The mapped hash
  # @see #map_keys
  # @see #map_vals
  def map_hash(hash)
    # Copy and modify is more performant than mapping to an array and using
    # to_hash on the result.
    rv = hash.class.new
    hash.each do |k, v|
      new_key, new_value = yield(k, v)
      new_key = hash.denormalize(new_key) if hash.is_a?(NormalizedMap) && new_key == k
      rv[new_key] = new_value
    end
    rv
  end

  # Restricts a number to falling within a given range.
  # Returns the number if it falls within the range,
  # or the closest value in the range if it doesn't.
  #
  # @param value [Numeric]
  # @param range [Range<Numeric>]
  # @return [Numeric]
  def restrict(value, range)
    [[value, range.first].max, range.last].min
  end

  # Like [Fixnum.round], but leaves rooms for slight floating-point
  # differences.
  #
  # @param value [Numeric]
  # @return [Numeric]
  def round(value)
    # If the number is within epsilon of X.5, round up (or down for negative
    # numbers).
    mod = value % 1
    mod_is_half = (mod - 0.5).abs < SassC::Script::Value::Number.epsilon
    if value > 0
      !mod_is_half && mod < 0.5 ? value.floor : value.ceil
    else
      mod_is_half || mod < 0.5 ? value.floor : value.ceil
    end
  end

  # Return an array of all possible paths through the given arrays.
  #
  # @param arrs [Array<Array>]
  # @return [Array<Arrays>]
  #
  # @example
  #   paths([[1, 2], [3, 4], [5]]) #=>
  #     # [[1, 3, 5],
  #     #  [2, 3, 5],
  #     #  [1, 4, 5],
  #     #  [2, 4, 5]]
  def paths(arrs)
    arrs.inject([[]]) do |paths, arr|
      arr.map {|e| paths.map {|path| path + [e]}}.flatten(1)
    end
  end

  # Returns a string description of the character that caused an
  # `Encoding::UndefinedConversionError`.
  #
  # @param e [Encoding::UndefinedConversionError]
  # @return [String]
  def undefined_conversion_error_char(e)
    # Rubinius (as of 2.0.0.rc1) pre-quotes the error character.
    return e.error_char if rbx?
    # JRuby (as of 1.7.2) doesn't have an error_char field on
    # Encoding::UndefinedConversionError.
    return e.error_char.dump unless jruby?
    e.message[/^"[^"]+"/] # "
  end

  # Asserts that `value` falls within `range` (inclusive), leaving
  # room for slight floating-point errors.
  #
  # @param name [String] The name of the value. Used in the error message.
  # @param range [Range] The allowed range of values.
  # @param value [Numeric, Sass::Script::Value::Number] The value to check.
  # @param unit [String] The unit of the value. Used in error reporting.
  # @return [Numeric] `value` adjusted to fall within range, if it
  #   was outside by a floating-point margin.
  def check_range(name, range, value, unit = '')
    grace = (-0.00001..0.00001)
    str = value.to_s
    value = value.value if value.is_a?(SassC::Script::Value::Number)
    return value if range.include?(value)
    return range.first if grace.include?(value - range.first)
    return range.last if grace.include?(value - range.last)
    raise ArgumentError.new(
      "#{name} #{str} must be between #{range.first}#{unit} and #{range.last}#{unit}")
  end

  # Returns information about the caller of the previous method.
  #
  # @param entry [String] An entry in the `#caller` list, or a similarly formatted string
  # @return [[String, Integer, (String, nil)]]
  #   An array containing the filename, line, and method name of the caller.
  #   The method name may be nil
  def caller_info(entry = nil)
    # JRuby evaluates `caller` incorrectly when it's in an actual default argument.
    entry ||= caller[1]
    info = entry.scan(/^((?:[A-Za-z]:)?.*?):(-?.*?)(?::.*`(.+)')?$/).first
    info[1] = info[1].to_i
    # This is added by Rubinius to designate a block, but we don't care about it.
    info[2].sub!(/ \{\}\Z/, '') if info[2]
    info
  end

  # Returns whether one version string represents a more recent version than another.
  #
  # @param v1 [String] A version string.
  # @param v2 [String] Another version string.
  # @return [Boolean]
  def version_gt(v1, v2)
    # Construct an array to make sure the shorter version is padded with nil
    Array.new([v1.length, v2.length].max).zip(v1.split("."), v2.split(".")) do |_, p1, p2|
      p1 ||= "0"
      p2 ||= "0"
      release1 = p1 =~ /^[0-9]+$/
      release2 = p2 =~ /^[0-9]+$/
      if release1 && release2
        # Integer comparison if both are full releases
        p1, p2 = p1.to_i, p2.to_i
        next if p1 == p2
        return p1 > p2
      elsif !release1 && !release2
        # String comparison if both are prereleases
        next if p1 == p2
        return p1 > p2
      else
        # If only one is a release, that one is newer
        return release1
      end
    end
  end

  # Returns whether one version string represents the same or a more
  # recent version than another.
  #
  # @param v1 [String] A version string.
  # @param v2 [String] Another version string.
  # @return [Boolean]
  def version_geq(v1, v2)
    version_gt(v1, v2) || !version_gt(v2, v1)
  end

  # Throws a NotImplementedError for an abstract method.
  #
  # @param obj [Object] `self`
  # @raise [NotImplementedError]
  def abstract(obj)
    raise NotImplementedError.new("#{obj.class} must implement ##{caller_info[2]}")
  end

  # Prints a deprecation warning for the caller method.
  #
  # @param obj [Object] `self`
  # @param message [String] A message describing what to do instead.
  def deprecated(obj, message = nil)
    obj_class = obj.is_a?(Class) ? "#{obj}." : "#{obj.class}#"
    full_message = "DEPRECATION WARNING: #{obj_class}#{caller_info[2]} " +
      "will be removed in a future version of Sass.#{("\n" + message) if message}"
    SassC::Util.sass_warn full_message
  end

  # Silences all Sass warnings within a block.
  #
  # @yield A block in which no Sass warnings will be printed
  def silence_sass_warnings
    old_level, Sass.logger.log_level = Sass.logger.log_level, :error
    yield
  ensure
    SassC.logger.log_level = old_level
  end

  # The same as `Kernel#warn`, but is silenced by \{#silence\_sass\_warnings}.
  #
  # @param msg [String]
  def sass_warn(msg)
    Sass.logger.warn("#{msg}\n")
  end

  ## Cross Rails Version Compatibility

  # Returns the root of the Rails application,
  # if this is running in a Rails context.
  # Returns `nil` if no such root is defined.
  #
  # @return [String, nil]
  def rails_root
    if defined?(::Rails.root)
      return ::Rails.root.to_s if ::Rails.root
      raise "ERROR: Rails.root is nil!"
    end
    return RAILS_ROOT.to_s if defined?(RAILS_ROOT)
    nil
  end

  # Returns the environment of the Rails application,
  # if this is running in a Rails context.
  # Returns `nil` if no such environment is defined.
  #
  # @return [String, nil]
  def rails_env
    return ::Rails.env.to_s if defined?(::Rails.env)
    return RAILS_ENV.to_s if defined?(RAILS_ENV)
    nil
  end

  # Returns whether this environment is using ActionPack
  # version 3.0.0 or greater.
  #
  # @return [Boolean]
  def ap_geq_3?
    ap_geq?("3.0.0.beta1")
  end

  # Returns whether this environment is using ActionPack
  # of a version greater than or equal to that specified.
  #
  # @param version [String] The string version number to check against.
  #   Should be greater than or equal to Rails 3,
  #   because otherwise ActionPack::VERSION isn't autoloaded
  # @return [Boolean]
  def ap_geq?(version)
    # The ActionPack module is always loaded automatically in Rails >= 3
    return false unless defined?(ActionPack) && defined?(ActionPack::VERSION) &&
      defined?(ActionPack::VERSION::STRING)

    version_geq(ActionPack::VERSION::STRING, version)
  end

  # Returns an ActionView::Template* class.
  # In pre-3.0 versions of Rails, most of these classes
  # were of the form `ActionView::TemplateFoo`,
  # while afterwards they were of the form `ActionView;:Template::Foo`.
  #
  # @param name [#to_s] The name of the class to get.
  #   For example, `:Error` will return `ActionView::TemplateError`
  #   or `ActionView::Template::Error`.
  def av_template_class(name)
    return ActionView.const_get("Template#{name}") if ActionView.const_defined?("Template#{name}")
    ActionView::Template.const_get(name.to_s)
  end

  ## Cross-OS Compatibility
  #
  # These methods are cached because some of them are called quite frequently
  # and even basic checks like String#== are too costly to be called repeatedly.

  # Whether or not this is running on Windows.
  #
  # @return [Boolean]
  def windows?
    return @windows if defined?(@windows)
    @windows = (RbConfig::CONFIG['host_os'] =~ /mswin|windows|mingw/i)
  end

  # Whether or not this is running on IronRuby.
  #
  # @return [Boolean]
  def ironruby?
    return @ironruby if defined?(@ironruby)
    @ironruby = RUBY_ENGINE == "ironruby"
  end

  # Whether or not this is running on Rubinius.
  #
  # @return [Boolean]
  def rbx?
    return @rbx if defined?(@rbx)
    @rbx = RUBY_ENGINE == "rbx"
  end

  # Whether or not this is running on JRuby.
  #
  # @return [Boolean]
  def jruby?
    return @jruby if defined?(@jruby)
    @jruby = RUBY_PLATFORM =~ /java/
  end

  # Returns an array of ints representing the JRuby version number.
  #
  # @return [Array<Integer>]
  def jruby_version
    @jruby_version ||= ::JRUBY_VERSION.split(".").map {|s| s.to_i}
  end

  # Like `Dir.glob`, but works with backslash-separated paths on Windows.
  #
  # @param path [String]
  def glob(path)
    path = path.tr('\\', '/') if windows?
    if block_given?
      Dir.glob(path) {|f| yield(f)}
    else
      Dir.glob(path)
    end
  end

  # Like `Pathname.new`, but normalizes Windows paths to always use backslash
  # separators.
  #
  # `Pathname#relative_path_from` can break if the two pathnames aren't
  # consistent in their slash style.
  #
  # @param path [String]
  # @return [Pathname]
  def pathname(path)
    path = path.tr("/", "\\") if windows?
    Pathname.new(path)
  end

  # Like `Pathname#cleanpath`, but normalizes Windows paths to always use
  # backslash separators. Normally, `Pathname#cleanpath` actually does the
  # reverse -- it will convert backslashes to forward slashes, which can break
  # `Pathname#relative_path_from`.
  #
  # @param path [String, Pathname]
  # @return [Pathname]
  def cleanpath(path)
    path = Pathname.new(path) unless path.is_a?(Pathname)
    pathname(path.cleanpath.to_s)
  end

  # Returns `path` with all symlinks resolved.
  #
  # @param path [String, Pathname]
  # @return [Pathname]
  def realpath(path)
    path = Pathname.new(path) unless path.is_a?(Pathname)

    # Explicitly DON'T run #pathname here. We don't want to convert
    # to Windows directory separators because we're comparing these
    # against the paths returned by Listen, which use forward
    # slashes everywhere.
    begin
      path.realpath
    rescue SystemCallError
      # If [path] doesn't actually exist, don't bail, just
      # return the original.
      path
    end
  end

  # Returns `path` relative to `from`.
  #
  # This is like `Pathname#relative_path_from` except it accepts both strings
  # and pathnames, it handles Windows path separators correctly, and it throws
  # an error rather than crashing if the paths use different encodings
  # (https://github.com/ruby/ruby/pull/713).
  #
  # @param path [String, Pathname]
  # @param from [String, Pathname]
  # @return [Pathname?]
  def relative_path_from(path, from)
    pathname(path.to_s).relative_path_from(pathname(from.to_s))
  rescue NoMethodError => e
    raise e unless e.name == :zero?

    # Work around https://github.com/ruby/ruby/pull/713.
    path = path.to_s
    from = from.to_s
    raise ArgumentError("Incompatible path encodings: #{path.inspect} is #{path.encoding}, " +
      "#{from.inspect} is #{from.encoding}")
  end

  # Converts `path` to a "file:" URI. This handles Windows paths correctly.
  #
  # @param path [String, Pathname]
  # @return [String]
  def file_uri_from_path(path)
    path = path.to_s if path.is_a?(Pathname)
    path = path.tr('\\', '/') if windows?
    path = URI::DEFAULT_PARSER.escape(path)
    return path.start_with?('/') ? "file://" + path : path unless windows?
    return "file:///" + path.tr("\\", "/") if path =~ %r{^[a-zA-Z]:[/\\]}
    return "file:" + path.tr("\\", "/") if path =~ %r{\\\\[^\\]+\\[^\\/]+}
    path.tr("\\", "/")
  end

  # Retries a filesystem operation if it fails on Windows. Windows
  # has weird and flaky locking rules that can cause operations to fail.
  #
  # @yield [] The filesystem operation.
  def retry_on_windows
    return yield unless windows?

    begin
      yield
    rescue SystemCallError
      sleep 0.1
      yield
    end
  end

  # Prepare a value for a destructuring assignment (e.g. `a, b =
  # val`). This works around a performance bug when using
  # ActiveSupport, and only needs to be called when `val` is likely
  # to be `nil` reasonably often.
  #
  # See [this bug report](http://redmine.ruby-lang.org/issues/4917).
  #
  # @param val [Object]
  # @return [Object]
  def destructure(val)
    val || []
  end

  CHARSET_REGEXP = /\A@charset "([^"]+)"/
  bom = "\uFEFF"
  UTF_8_BOM = bom.encode("UTF-8").force_encoding('BINARY')
  UTF_16BE_BOM = bom.encode("UTF-16BE").force_encoding('BINARY')
  UTF_16LE_BOM = bom.encode("UTF-16LE").force_encoding('BINARY')

  ## Cross-Ruby-Version Compatibility

  # Whether or not this is running under Ruby 2.4 or higher.
  #
  # @return [Boolean]
  def ruby2_4?
    return @ruby2_4 if defined?(@ruby2_4)
    @ruby2_4 =
      if RUBY_VERSION_COMPONENTS[0] == 2
        RUBY_VERSION_COMPONENTS[1] >= 4
      else
        RUBY_VERSION_COMPONENTS[0] > 2
      end
  end

  # Allows modifications to be performed on the string form
  # of an array containing both strings and non-strings.
  #
  # @param arr [Array] The array from which values are extracted.
  # @yield [str] A block in which string manipulation can be done to the array.
  # @yieldparam str [String] The string form of `arr`.
  # @yieldreturn [String] The modified string.
  # @return [Array] The modified, interpolated array.
  def with_extracted_values(arr)
    str, vals = extract_values(arr)
    str = yield str
    inject_values(str, vals)
  end

  # Builds a sourcemap file name given the generated CSS file name.
  #
  # @param css [String] The generated CSS file name.
  # @return [String] The source map file name.
  def sourcemap_name(css)
    css + ".map"
  end

  # Escapes certain characters so that the result can be used
  # as the JSON string value. Returns the original string if
  # no escaping is necessary.
  #
  # @param s [String] The string to be escaped
  # @return [String] The escaped string
  def json_escape_string(s)
    return s if s !~ /["\\\b\f\n\r\t]/

    result = ""
    s.split("").each do |c|
      case c
      when '"', "\\"
        result << "\\" << c
      when "\n" then result << "\\n"
      when "\t" then result << "\\t"
      when "\r" then result << "\\r"
      when "\f" then result << "\\f"
      when "\b" then result << "\\b"
      else
        result << c
      end
    end
    result
  end

  # Converts the argument into a valid JSON value.
  #
  # @param v [Integer, String, Array, Boolean, nil]
  # @return [String]
  def json_value_of(v)
    case v
    when Integer
      v.to_s
    when String
      "\"" + json_escape_string(v) + "\""
    when Array
      "[" + v.map {|x| json_value_of(x)}.join(",") + "]"
    when NilClass
      "null"
    when TrueClass
      "true"
    when FalseClass
      "false"
    else
      raise ArgumentError.new("Unknown type: #{v.class.name}")
    end
  end

  VLQ_BASE_SHIFT = 5
  VLQ_BASE = 1 << VLQ_BASE_SHIFT
  VLQ_BASE_MASK = VLQ_BASE - 1
  VLQ_CONTINUATION_BIT = VLQ_BASE

  BASE64_DIGITS = ('A'..'Z').to_a + ('a'..'z').to_a + ('0'..'9').to_a + ['+', '/']
  BASE64_DIGIT_MAP = begin
    map = {}
    BASE64_DIGITS.each_with_index.map do |digit, i|
      map[digit] = i
    end
    map
  end

  # Encodes `value` as VLQ (http://en.wikipedia.org/wiki/VLQ).
  #
  # @param value [Integer]
  # @return [String] The encoded value
  def encode_vlq(value)
    if value < 0
      value = ((-value) << 1) | 1
    else
      value <<= 1
    end

    result = ''
    begin
      digit = value & VLQ_BASE_MASK
      value >>= VLQ_BASE_SHIFT
      if value > 0
        digit |= VLQ_CONTINUATION_BIT
      end
      result << BASE64_DIGITS[digit]
    end while value > 0
    result
  end

  ## Static Method Stuff

  # The context in which the ERB for \{#def\_static\_method} will be run.
  class StaticConditionalContext
    # @param set [#include?] The set of variables that are defined for this context.
    def initialize(set)
      @set = set
    end

    # Checks whether or not a variable is defined for this context.
    #
    # @param name [Symbol] The name of the variable
    # @return [Boolean]
    def method_missing(name, *args)
      super unless args.empty? && !block_given?
      @set.include?(name)
    end
  end

  # @private
  ATOMIC_WRITE_MUTEX = Mutex.new

  # This creates a temp file and yields it for writing. When the
  # write is complete, the file is moved into the desired location.
  # The atomicity of this operation is provided by the filesystem's
  # rename operation.
  #
  # @param filename [String] The file to write to.
  # @param perms [Integer] The permissions used for creating this file.
  #   Will be masked by the process umask. Defaults to readable/writeable
  #   by all users however the umask usually changes this to only be writable
  #   by the process's user.
  # @yieldparam tmpfile [Tempfile] The temp file that can be written to.
  # @return The value returned by the block.
  def atomic_create_and_write_file(filename, perms = 0666)
    require 'tempfile'
    tmpfile = Tempfile.new(File.basename(filename), File.dirname(filename))
    tmpfile.binmode if tmpfile.respond_to?(:binmode)
    result = yield tmpfile
    tmpfile.close
    ATOMIC_WRITE_MUTEX.synchronize do
      begin
        File.chmod(perms & ~File.umask, tmpfile.path)
      rescue Errno::EPERM
        # If we don't have permissions to chmod the file, don't let that crash
        # the compilation. See issue 1215.
      end
      File.rename tmpfile.path, filename
    end
    result
  ensure
    # close and remove the tempfile if it still exists,
    # presumably due to an error during write
    tmpfile.close if tmpfile
    tmpfile.unlink if tmpfile
  end

  private

  def find_encoding_error(str)
    encoding = str.encoding
    cr = Regexp.quote("\r".encode(encoding).force_encoding('BINARY'))
    lf = Regexp.quote("\n".encode(encoding).force_encoding('BINARY'))
    ff = Regexp.quote("\f".encode(encoding).force_encoding('BINARY'))
    line_break = /#{cr}#{lf}?|#{ff}|#{lf}/

    str.force_encoding("binary").split(line_break).each_with_index do |line, i|
      begin
        line.encode(encoding)
      rescue Encoding::UndefinedConversionError => e
        raise SassC::SyntaxError.new(
          "Invalid #{encoding.name} character #{undefined_conversion_error_char(e)}",
          :line => i + 1)
      end
    end

    # We shouldn't get here, but it's possible some weird encoding stuff causes it.
    return str, str.encoding
  end

  singleton_methods.each {|method| module_function method}
end
