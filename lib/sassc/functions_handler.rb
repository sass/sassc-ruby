module SassC
  class FunctionsHandler
    def initialize(options)
      @options = options
    end

    def setup(native_options)
      Script.setup_custom_functions(native_options, @options)
    end

    private
  end
end
