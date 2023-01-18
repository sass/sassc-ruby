# frozen_string_literal: true

module SassC
  class FunctionsHandler
    def initialize(options)
      @options = options
    end

    def setup(_native_options, functions: Script::Functions)
      @callbacks = {}

      functions_wrapper = Class.new do
        attr_accessor :options

        include functions
      end.new
      functions_wrapper.options = @options

      Script.custom_functions(functions: functions).each do |custom_function|
        callback = lambda do |native_argument_list|
          function_arguments = arguments_from_native_list(native_argument_list)
          begin
            result = functions_wrapper.send(custom_function, *function_arguments)
          rescue StandardError
            raise ::Sass::ScriptError, "Error: error in C function #{custom_function}"
          end
          to_native_value(result)
        rescue StandardError => e
          warn "[SassC::FunctionsHandler] #{e.cause.message}"
          raise e
        end

        @callbacks[Script.formatted_function_name(custom_function, functions: functions)] = callback
      end

      @callbacks
    end

    private

    def arguments_from_native_list(native_argument_list)
      native_argument_list.map do |native_value|
        Script::ValueConversion.from_native(native_value, @options)
      end.compact
    end

    def to_native_value(sass_value)
      # if the custom function returns nil, we provide a "default" return
      # value of an empty string
      sass_value ||= SassC::Script::Value::String.new("")
      sass_value.options = @options
      Script::ValueConversion.to_native(sass_value)
    end

    def error(message)
      $stderr.puts "[SassC::FunctionsHandler] #{message}"
      Native.make_error(message)
    end

    begin
      begin
        raise RuntimeError
      rescue StandardError
        raise ::Sass::ScriptError
      end
    rescue StandardError => e
      unless e.full_message.include?(e.cause.full_message)
        ::Sass::ScriptError.class_eval do
          def full_message(*args, **kwargs)
            full_message = super(*args, **kwargs)
            if cause
              "#{full_message}\n#{cause.full_message(*args, **kwargs)}"
            else
              full_message
            end
          end
        end
      end
    end
  end
end
