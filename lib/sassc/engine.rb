module SassC
  class Engine
    def initialize(template, options = {})
      @template = template
      @options = options

      # filename: input[:filename],
      # syntax: self.class.syntax,
      # cache_store: CacheStore.new(input[:cache], @cache_version),
      # load_paths: input[:environment].paths
    end

    def render
      data_context = SassC::Native.make_data_context(@template)
      context = SassC::Native.data_context_get_context(data_context)
      options = SassC::Native.context_get_options(context)

      SassC::Native.option_set_is_indented_syntax_src(options, true) if sass?
      SassC::Native.option_set_input_path(options, filename) if filename

      status = SassC::Native.compile_data_context(data_context)
      css = SassC::Native.context_get_output_string(context)

      SassC::Native.delete_data_context(data_context)

      return css unless quiet?
    end

    private

    def quiet?
      @options[:quiet]
    end

    def filename
      @options[:filename]
    end

    def sass?
      @options[:syntax] == "sass"
    end
  end
end
