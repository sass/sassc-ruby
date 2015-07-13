require_relative "test_helper"
require "stringio"

module SassC
  class FunctionsTest < MiniTest::Test
    include FixtureHelper

    def setup
      @real_stderr, $stderr = $stderr, StringIO.new
    end

    def teardown
      $stderr = @real_stderr
    end

    def test_functions_may_return_sass_string_type
      engine = Engine.new(<<-SCSS)
div {
  url: url(sass_return_path("foo.svg")); }
      SCSS

      assert_equal <<-EXPECTED_SCSS, engine.render
div {
  url: url("foo.svg"); }
      EXPECTED_SCSS
    end

    def test_functions_work_with_varying_quotes_and_string_types
      filename = fixture_path('paths.scss')
      data = File.read(filename)

      engine = Engine.new(data, {
        filename: filename,
        syntax: :scss
      })

      assert_equal <<-EOS, engine.render
div {
  url: url(asset-path("foo.svg"));
  url: url(image-path("foo.png"));
  url: url(video-path("foo.mov"));
  url: url(audio-path("foo.mp3"));
  url: url(font-path("foo.woff"));
  url: url("/js/foo.js");
  url: url("/js/foo.js");
  url: url(/css/foo.css); }
      EOS
    end

    def test_function_with_no_return_value
      engine = Engine.new("div {url: url(no-return-path('foo.svg'));}")

      assert_equal <<-EOS, engine.render
div {
  url: url(); }
      EOS
    end

    def test_function_that_returns_a_color
      engine = Engine.new(<<-SCSS)
div {
  background: returns-a-color(); }
      SCSS

      assert_equal <<-EXPECTED_SCSS, engine.render
div {
  background: black; }
      EXPECTED_SCSS
    end

    def test_function_with_optional_arguments
      engine = Engine.new(<<-SCSS)
div {
  url: optional_arguments('first');
  url: optional_arguments('second', 'qux'); }
SCSS

      assert_equal <<-EXPECTED_SCSS, engine.render
div {
  url: "first/bar";
  url: "second/qux"; }
      EXPECTED_SCSS
    end

    def test_functions_may_accept_sass_color_type
      engine = Engine.new("div { color: nice_color_argument(red); }")
      assert_equal <<-EOS, engine.render
div {
  color: "red"; }
      EOS
    end

    def test_function_with_unsupported_tag
      engine = Engine.new("div {url: function_with_unsupported_tag(1);}")

      exception = assert_raises(SassC::SyntaxError) do
        engine.render
      end

      assert_equal "Error: error in C function function_with_unsupported_tag: Sass argument of type sass_number unsupported\n\n       Backtrace:\n       \tstdin:1, in function `function_with_unsupported_tag`\n       \tstdin:1\n        on line 1 of stdin\n>> div {url: function_with_unsupported_tag(1);}\n   ----------^\n", exception.message

      assert_equal "[SassC::FunctionsHandler] Sass argument of type sass_number unsupported", stderr_output
    end

    def test_function_with_error
      engine = Engine.new("div {url: function_that_raises_errors();}")
      exception = assert_raises(SassC::SyntaxError) do
        engine.render
      end

      assert_equal "Error: error in C function function_that_raises_errors: Intentional wrong thing happened somewhere inside the custom function

       Backtrace:
       \tstdin:1, in function `function_that_raises_errors`
       \tstdin:1
        on line 1 of stdin
>> div {url: function_that_raises_errors();}
   ----------^
", exception.message

      assert_equal "[SassC::FunctionsHandler] Intentional wrong thing happened somewhere inside the custom function", stderr_output
    end

    private

    module Script::Functions
      def javascript_path(path)
        Script::String.new("/js/#{path.value}", :string)
      end

      def no_return_path(path)
        nil
      end

      def sass_return_path(path)
        Script::String.new("#{path.value}", :string)
      end

      def optional_arguments(path, optional = "bar")
        Script::String.new("#{path.value}/#{optional}", :string)
      end

      def function_that_raises_errors()
        raise StandardError, "Intentional wrong thing happened somewhere inside the custom function"
      end

      def function_with_unsupported_tag(number)
      end

      def nice_color_argument(color)
        return Script::String.new(color.to_s, :string)
      end

      def returns_a_color()
        return Script::Color.new(red: 0, green: 0, blue: 0)
      end

      module Compass
        def stylesheet_path(path)
          Script::String.new("/css/#{path.value}", :identifier)
        end
      end
      include Compass
    end

    def stderr_output
      $stderr.string.gsub("\u0000\n", '').chomp
    end
  end
end
