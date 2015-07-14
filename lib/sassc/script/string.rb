require 'sass/script/value/string'

module SassC
  module Script
    module NativeString
      def to_native(opts = {})
        if opts[:quote] == :none || type == :identifier
          Native::make_string(to_s)
        else
          Native::make_qstring(to_s)
        end
      end
    end

    class String < ::Sass::Script::Value::String
      include NativeString
    end
  end
end
