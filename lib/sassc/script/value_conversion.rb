# frozen_string_literal: true

module SassC::Script::ValueConversion

  def self.from_native(value, options)
    case value
    when ::Sass::Value::Null::NULL
      nil
    when ::Sass::Value::Boolean
      ::SassC::Script::Value::Bool.new(value.to_bool)
    when ::Sass::Value::Color
      if value.instance_eval { defined? @hue }
        ::SassC::Script::Value::Color.new(
          hue: value.hue,
          saturation: value.saturation,
          lightness: value.lightness,
          alpha: value.alpha
        )
      else
        ::SassC::Script::Value::Color.new(
          red: value.red,
          green: value.green,
          blue: value.blue,
          alpha: value.alpha
        )
      end
    when ::Sass::Value::List
      ::SassC::Script::Value::List.new(
        value.to_a.map { |element| from_native(element, options) },
        separator: case value.separator
                   when ','
                     :comma
                   when ' '
                     :space
                   else
                     raise UnsupportedValue, "Sass list separator #{value.separator} unsupported"
                   end,
        bracketed: value.bracketed?
      )
    when ::Sass::Value::Map
      ::SassC::Script::Value::Map.new(
        value.contents.to_a.to_h { |k, v| [from_native(k, options), from_native(v, options)] }
      )
    when ::Sass::Value::Number
      ::SassC::Script::Value::Number.new(
        value.value,
        value.numerator_units,
        value.denominator_units
      )
    when ::Sass::Value::String
      ::SassC::Script::Value::String.new(
        value.text,
        value.quoted? ? :string : :identifier
      )
    else
      raise UnsupportedValue, "Sass argument of type #{value.class.name.split('::').last} unsupported"
    end
  end

  def self.to_native(value)
    case value
    when nil
      ::Sass::Value::Null::NULL
    when ::SassC::Script::Value::Bool
      ::Sass::Value::Boolean.new(value.to_bool)
    when ::SassC::Script::Value::Color
      if value.rgba?
        ::Sass::Value::Color.new(
          red: value.red,
          green: value.green,
          blue: value.blue,
          alpha: value.alpha
        )
      elsif value.hlsa?
        ::Sass::Value::Color.new(
          hue: value.hue,
          saturation: value.saturation,
          lightness: value.lightness,
          alpha: value.alpha
        )
      else
        raise UnsupportedValue, "Sass color mode #{value.instance_eval { @mode }} unsupported"
      end
    when ::SassC::Script::Value::List
      ::Sass::Value::List.new(
        value.to_a.map { |element| to_native(element) },
        separator: case value.separator
                   when :comma
                     ','
                   when :space
                     ' '
                   else
                     raise UnsupportedValue, "Sass list separator #{value.separator} unsupported"
                   end,
        bracketed: value.bracketed
      )
    when ::SassC::Script::Value::Map
      ::Sass::Value::Map.new(
        value.value.to_a.to_h { |k, v| [to_native(k), to_native(v)] }
      )
    when ::SassC::Script::Value::Number
      ::Sass::Value::Number.new(
        value.value, {
          numerator_units: value.numerator_units,
          denominator_units: value.denominator_units
        }
      )
    when ::SassC::Script::Value::String
      ::Sass::Value::String.new(
        value.value,
        quoted: value.type != :identifier
      )
    else
      raise UnsupportedValue, "Sass return type #{value.class.name.split('::').last} unsupported"
    end
  end
end
