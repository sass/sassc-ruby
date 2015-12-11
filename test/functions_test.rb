require_relative "test_helper"
require "stringio"
require "sass/script"

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
      assert_sass <<-SCSS, <<-CSS
        div { url: url(sass_return_path("foo.svg")); }
      SCSS
        div { url: url("foo.svg"); }
      CSS
    end

    def test_functions_work_with_varying_quotes_and_string_types
      assert_sass <<-SCSS, <<-CSS
        div {
           url: url(asset-path("foo.svg"));
           url: url(image-path("foo.png"));
           url: url(video-path("foo.mov"));
           url: url(audio-path("foo.mp3"));
           url: url(font-path("foo.woff"));
           url: url(javascript-path('foo.js'));
           url: url(javascript-path("foo.js"));
           url: url(stylesheet-path("foo.css"));
        }
      SCSS
        div {
          url: url(asset-path("foo.svg"));
          url: url(image-path("foo.png"));
          url: url(video-path("foo.mov"));
          url: url(audio-path("foo.mp3"));
          url: url(font-path("foo.woff"));
          url: url("/js/foo.js");
          url: url("/js/foo.js");
          url: url(/css/foo.css);
        }
      CSS
    end

    def test_function_with_no_return_value
      assert_sass <<-SCSS, <<-CSS
        div {url: url(no-return-path('foo.svg'));}
      SCSS
        div { url: url(); }
      CSS
    end

    def test_function_that_returns_a_color
      assert_sass <<-SCSS, <<-CSS
        div { background: returns-a-color(); }
      SCSS
        div { background: black; }
      CSS
    end

    def test_function_with_optional_arguments
      assert_sass <<-SCSS, <<-EXPECTED_CSS
        div {
          url: optional_arguments('first');
          url: optional_arguments('second', 'qux');
        }
      SCSS
        div {
          url: "first/bar";
          url: "second/qux";
        }
      EXPECTED_CSS
    end

    def test_functions_may_accept_sass_color_type
      assert_sass <<-SCSS, <<-EXPECTED_CSS
        div { color: nice_color_argument(red); }
      SCSS
        div { color: "red"; }
      EXPECTED_CSS
    end

    def test_function_with_unsupported_tag
      engine = Engine.new("div {url: function_with_unsupported_tag(1);}")

      exception = assert_raises(SassC::SyntaxError) do
        engine.render
      end

      assert_match /Sass argument of type sass_number unsupported/, exception.message
      assert_equal "[SassC::FunctionsHandler] Sass argument of type sass_number unsupported", stderr_output
    end

    def test_function_with_error
      engine = Engine.new("div {url: function_that_raises_errors();}")

      exception = assert_raises(SassC::SyntaxError) do
        engine.render
      end

      assert_match /Error: error in C function function_that_raises_errors/, exception.message
      assert_match /Intentional wrong thing happened somewhere inside the custom function/, exception.message
      assert_equal "[SassC::FunctionsHandler] Intentional wrong thing happened somewhere inside the custom function", stderr_output
    end

    def test_function_that_returns_a_sass_value
      assert_sass <<-SCSS, <<-CSS
        div { background: returns-sass-value(); }
      SCSS
        div { background: black; }
      CSS
    end

    private

    def assert_sass(sass, expected_css)
      engine = Engine.new(sass)
      assert_equal expected_css.strip.gsub!(/\s+/, " "), # poor man's String#squish
                   engine.render.strip.gsub!(/\s+/, " ")
    end

    def stderr_output
      $stderr.string.gsub("\u0000\n", '').chomp
    end

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

      def optional_arguments(path, optional = nil)
        optional ||= Script::String.new("bar")
        Script::String.new("#{path.value}/#{optional.value}", :string)
      end

      def function_that_raises_errors
        raise StandardError, "Intentional wrong thing happened somewhere inside the custom function"
      end

      def function_with_unsupported_tag(number)
      end

      def nice_color_argument(color)
        return Script::String.new(color.to_s, :string)
      end

      def returns_a_color
        return Script::Color.new(red: 0, green: 0, blue: 0)
      end

      def returns_sass_value
        return Sass::Script::Value::Color.new(red: 0, green: 0, blue: 0)
      end

      module Compass
        def stylesheet_path(path)
          Script::String.new("/css/#{path.value}", :identifier)
        end
      end
      include Compass
    end
  end
end
