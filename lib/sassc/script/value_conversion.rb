module SassC
  module Script
    module ValueConversion
      def self.from_native(native_value, options)
        case value_tag = Native.value_get_tag(native_value)
        when :sass_null
          # no-op
        when :sass_string
          value = Native.string_get_value(native_value)
          type = Native.string_get_type(native_value)
          argument = Script::String.new(value, type)

          argument
        when :sass_boolean
          value = Native.boolean_get_value(native_value)
          argument = Script::Bool.new(value)
          
          argument
        when :sass_number
          value = Native.number_get_value(native_value)
          unit = Native.number_get_unit(native_value)
          argument = Sass::Script::Value::Number.new(value, unit)

          argument
        when :sass_color
          red, green, blue, alpha = Native.color_get_r(native_value), Native.color_get_g(native_value), Native.color_get_b(native_value), Native.color_get_a(native_value)

          argument = Script::Color.new([red, green, blue, alpha])
          argument.options = options

          argument
        when :sass_map
          values = {}
          length = Native::map_get_length native_value

          (0..length-1).each do |index|
            key = Native::map_get_key(native_value, index)
            value = Native::map_get_value(native_value, index)
            values[from_native(key, options)] = from_native(value, options)
          end

          argument = Sass::Script::Value::Map.new values
          argument
        when :sass_list
          length = Native::list_get_length(native_value)
          items = (0...length).map do |index|
            native_item = Native::list_get_value(native_value, index)
            from_native(native_item, options)
          end

          if Gem.loaded_specs['sass'].version < Gem::Version.create('3.5')
            Sass::Script::Value::List.new(items, :space)
          else
            Sass::Script::Value::List.new(items, separator: :space)
          end
        else
          raise UnsupportedValue.new("Sass argument of type #{value_tag} unsupported")
        end
      end

      def self.to_native(value)
        case value_name = value.class.name.split("::").last
        when "String"
          String.new(value).to_native
        when "Color"
          Color.new(value).to_native
        when "Number"
          Number.new(value).to_native
        when "Map"
          Map.new(value).to_native
        when "List"
          List.new(value).to_native
        when "Bool"
          Bool.new(value).to_native
        else
          raise UnsupportedValue.new("Sass return type #{value_name} unsupported")
        end
      end
    end
  end
end

require_relative "value_conversion/base"
require_relative "value_conversion/string"
require_relative "value_conversion/number"
require_relative "value_conversion/color"
require_relative "value_conversion/map"
require_relative "value_conversion/list"
require_relative "value_conversion/bool"
