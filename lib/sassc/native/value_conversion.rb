module SassC
  module Native
    module ValueConversion
      class Unsupported < StandardError; end

      def self.from_native(native_value, options)
        case value_tag = Native.value_get_tag(native_value)
        when :sass_null
          # no-op
        when :sass_string
          value = Native.string_get_value(native_value)
          type = Native.string_get_type(native_value)
          argument = Script::String.new(value, type)

          argument
        when :sass_color
          red, green, blue, alpha = Native.color_get_r(native_value), Native.color_get_g(native_value), Native.color_get_b(native_value), Native.color_get_a(native_value)

          argument = Script::Color.new([red, green, blue, alpha])
          argument.options = options

          argument
        else
          raise Unsupported.new("Sass argument of type #{value_tag} unsupported")
        end
      end

      def self.to_native(value)
        case value_name = value.class.name.split("::").last
        when "String"
          String.new(value).to_native
        when "Color"
          Color.new(value).to_native
        else
          raise Unsupported.new("Sass return type #{value_name} unsupported")
        end
      end
    end
  end
end

require_relative "value_conversion/base"
require_relative "value_conversion/string"
require_relative "value_conversion/color"
