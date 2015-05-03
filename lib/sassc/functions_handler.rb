module SassC
  class FunctionsHandler
    def initialize(options)
      @options = options
    end

    def setup(native_options)
      @callbacks = {}
      @function_names = {}

      list = Native.make_function_list(Script.custom_functions.count)

      functs = FunctionWrapper.extend(Script::Functions)
      functs.options = @options

      Script.custom_functions.each_with_index do |custom_function, i|
        @callbacks[custom_function] = FFI::Function.new(:pointer, [:pointer, :pointer]) do |s_args, cookie|
          length = Native.list_get_length(s_args)

          v = Native.list_get_value(s_args, 0)
          v = Native.string_get_value(v).dup

          s = Script::String.new(Script::String.unquote(v), Script::String.type(v))

          value = functs.send(custom_function, s)

          if value
            value = Script::String.new(Script::String.unquote(value.to_s), value.type)
            value.to_native
          else
            Script::String.new("").to_native
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

    class FunctionWrapper
      class << self
        attr_accessor :options
      end
    end
  end
end
