module SassC
  module Script
    def self.custom_functions
      Functions.instance_methods.select do |function|
        Functions.public_method_defined?(function)
      end
    end

    def self.formatted_function_name(function_name)
      params = Functions.instance_method(function_name).parameters
      params = params.map { |param_type, name| "$#{name}#{': null' if param_type == :opt}" }
                     .join(", ")

      "#{function_name}(#{params})"
    end

    module Value
    end
  end
end

require_relative "script/functions"
require_relative "script/value_conversion"

module Sass
  module Script
  end
end

require 'sass/util'

begin
  require 'sass/deprecation'
rescue LoadError
end

require 'sass/script/value/base'
require 'sass/script/value/string'
require 'sass/script/value/color'
require 'sass/script/value/bool'

SassC::Script::String = Sass::Script::Value::String
SassC::Script::Value::String = Sass::Script::Value::String

SassC::Script::Color = Sass::Script::Value::Color
SassC::Script::Value::Color = Sass::Script::Value::Color

SassC::Script::Bool = Sass::Script::Value::Bool
SassC::Script::Value::Bool = Sass::Script::Value::Bool
