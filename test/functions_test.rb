require_relative "test_helper"

module SassC
  class FunctionsTest < MiniTest::Test
    include FixtureHelper

    SassString = Struct.new(:value, :type) do
      def to_s
        value
      end
    end

    module Script::Functions
      def javascript_path(path)
        Script::String.new("/js/#{path.value}", :string)
      end

      def no_return_path(path)
        nil
      end

      def sass_return_path(path)
        return SassString.new("'#{path.value}'", :string)
      end

      module Compass
        def stylesheet_path(path)
          Script::String.new("/css/#{path.value}", :identifier)
        end
      end
      include Compass
    end

    def test_functions_may_return_sass_string_type
      engine = Engine.new("div {url: url(sass_return_path('foo.svg'));}")

      assert_equal <<-EOS, engine.render
div {
  url: url("foo.svg"); }
      EOS
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
  end
end
