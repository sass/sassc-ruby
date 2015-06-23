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
  end
end

require_relative "script/functions"
require_relative "script/string"

module Sass
  module Script
  end
end

require 'sass/util'
require 'sass/script/value/base'
require_relative "script/color"
