require 'sass/script/value/string'

module SassC
  module Script
    class String < ::Sass::Script::Value::String
      def to_native(opts = {})
        if opts[:quote] == :none || type == :identifier
          Native::make_string(to_s)
        else
          Native::make_qstring(to_s)
        end
      end
    end
  end
end
