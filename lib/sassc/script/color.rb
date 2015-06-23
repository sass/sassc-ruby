require 'sass/script/value/color'

module SassC
  module Script
    class Color < ::Sass::Script::Value::Color
      def to_native
        Native::make_string(to_s)
      end
    end
  end
end
