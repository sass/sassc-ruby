require_relative "test_helper"

class FunctionsTest < SassCTest
  module ::SassC::Script::Functions
    def javascript_path(path)
      ::SassC::Script::String.new("/js/#{path.value}", :string)
    end

    def no_return_path(path)
      nil
    end

    module Compass
      def stylesheet_path(path)
        ::SassC::Script::String.new("/css/#{path.value}", :identifier)
      end
    end
    include Compass
  end

  def test_functions_work
    filename = fixture_path('paths.scss')
    assert data = File.read(filename)

    engine = ::SassC::Engine.new(data, {
      filename: filename,
      syntax: :scss
    })

    # test identifier / string types
    # test varying quotes

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
    filename = fixture_path('paths.scss')
    assert data = File.read(filename)

    engine = ::SassC::Engine.new("div {url: url(no-return-path('foo.svg'));}")

    assert_equal <<-EOS, engine.render
div {
  url: url(); }
      EOS
  end
end
