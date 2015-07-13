module SassC
  class FunctionsHandler
    def initialize(options)
      @options = options
    end

    def setup(native_options)
      @callbacks = {}
      @function_names = {}

      list = Native.make_function_list(Script.custom_functions.count)

      functions = FunctionWrapper.extend(Script::Functions)
      functions.options = @options

      Script.custom_functions.each_with_index do |custom_function, i|
        @callbacks[custom_function] = FFI::Function.new(:pointer, [:pointer, :pointer]) do |native_argument_list, cookie|
          native_argument_list_length = Native.list_get_length(native_argument_list)
          custom_function_arguments = []
          error_tag = nil

          (0...native_argument_list_length).each do |i|
            native_value = Native.list_get_value(native_argument_list, i)

            case value_tag = Native.value_get_tag(native_value)
            when :sass_null
              # no-op
            when :sass_string
              value = Native.string_get_value(native_value)
              type = Native.string_get_type(native_value)
              argument = Script::String.new(value, type)

              custom_function_arguments << argument
            when :sass_color
              red, green, blue, alpha = Native.color_get_r(native_value), Native.color_get_g(native_value), Native.color_get_b(native_value), Native.color_get_a(native_value)

              argument = Script::Color.new([red, green, blue, alpha])
              argument.options = @options

              custom_function_arguments << argument
            else
              error_tag = error("Sass argument of type #{value_tag} unsupported")
              break
            end
          end

          next error_tag if error_tag

          begin
            script_value = functions.send(custom_function, *custom_function_arguments)

            if script_value
              script_value.options = @options
              script_value.to_native
            else
              Script::String.new("").to_native
            end
          rescue StandardError => exception
            error(exception.message)
          end
        end

        @function_names[custom_function] = Script.formatted_function_name(custom_function)

        callback = Native.make_function(
          @function_names[custom_function],
          @callbacks[custom_function],
          nil
        )

        Native::function_set_list_entry(list, i, callback)
      end

      Native::option_set_c_functions(native_options, list)
    end

    private

    def error(message)
      $stderr.puts "[SassC::FunctionsHandler] #{message}"
      Native.make_error(message)
    end

    class FunctionWrapper
      class << self
        attr_accessor :options
      end
    end
  end
end
