require_relative "test_helper"

class FunctionsTest < SassCTest
  module ::SassC::Script::Functions
    def javascript_path(path)
      ::SassC::Script::String.new("/js/#{path.value}", :string)
    end

    module Compass
      def stylesheet_path(path)
        ::SassC::Script::String.new("/css/#{path.value}", :string)
      end
    end
    include Compass
  end

  test "aren't included globally" do
    assert ::SassC::Script::Functions.instance_methods.include?(:javascript_path)
    assert ::SassC::Script::Functions.instance_methods.include?(:stylesheet_path)

    filename = fixture_path('paths.scss')
    assert data = File.read(filename)
    engine = ::SassC::Engine.new(data, {
      filename: filename,
      syntax: :scss
    })

    assert ::SassC::Script::Functions.instance_methods.include?(:javascript_path)
    assert ::SassC::Script::Functions.instance_methods.include?(:stylesheet_path)

    assert_equal <<-EOS, engine.render
div {
  url: url(asset-path("foo.svg"));
  url: url(image-path("foo.png"));
  url: url(video-path("foo.mov"));
  url: url(audio-path("foo.mp3"));
  url: url(font-path("foo.woff"));
  url: url("/js/foo.js");
  url: url("/css/foo.css"); }
      EOS
  end
end
