module SassC
  module Script
    def self.custom_functions
      Functions.instance_methods.select do |function|
        Functions.public_method_defined?(function)
      end
    end

    def self.setup_custom_functions(options)
      callbacks = {}

      list = Native.make_function_list(custom_functions.count)

      functs = Class.new.extend(Functions)

      custom_functions.each_with_index do |custom_function, i|
        callbacks[custom_function] = FFI::Function.new(:pointer, [:pointer, :pointer]) do |s_args, cookie|
          length = Native.list_get_length(s_args)

          v = Native.list_get_value(s_args, 0)
          v = Native.string_get_value(v).dup

          s = String.new(String.unquote(v), String.type(v))
          functs.send(custom_function, s).to_native
        end

        callback = Native.make_function(
          formatted_function_name(custom_function),
          callbacks[custom_function],
          nil
        )

        Native::function_set_list_entry(list, i, callback);
      end

      Native::option_set_c_functions(options, list)

      status = yield

      callbacks

      status
    end

    def self.formatted_function_name(function_name)
      params = Functions.instance_method(function_name).parameters
      params = params.select { |param| param[0] == :req }
                     .map(&:first)
                     .map { |p| "$#{p}" }
                     .join(", ")
      "#{function_name}(#{params})"
    end
  end
end

require_relative "script/functions"
require_relative "script/string"
