require 'sass/script/value/color'

module SassC
  module Script
    module NativeColor
      def to_native
        Native::make_color(red, green, blue, alpha)
      end
    end

    class Color < ::Sass::Script::Value::Color
      include NativeColor
    end
  end
end
