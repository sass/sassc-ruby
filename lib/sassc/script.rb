module SassC
  module Script
    def self.custom_functions
      Functions.instance_methods.select do |function|
        Functions.public_method_defined?(function)
      end
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
