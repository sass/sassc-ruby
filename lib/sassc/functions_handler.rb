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
          begin
            function_arguments = arguments_from_native_list(native_argument_list)
            result = functions.send(custom_function, *function_arguments)
            to_native_value(result)
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

    def arguments_from_native_list(native_argument_list)
      native_argument_list_length = Native.list_get_length(native_argument_list)

      (0...native_argument_list_length).map do |i|
        native_value = Native.list_get_value(native_argument_list, i)
        Script::ValueConversion.from_native(native_value, @options)
      end.compact
    end

    def to_native_value(sass_value)
      sass_value ||= Script::String.new("") # null response
      sass_value.options = @options
      Script::ValueConversion.to_native(sass_value)
    end

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
