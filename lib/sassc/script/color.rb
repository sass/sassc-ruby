require 'sass/script/value/color'

module SassC
  module Script
    class Color < ::Sass::Script::Value::Color
      def to_native
        Native::make_color(red, green, blue, alpha)
      end
    end
  end
end
