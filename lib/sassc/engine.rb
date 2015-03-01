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
      data_context = Native.make_data_context(@template)
      context = Native.data_context_get_context(data_context)
      options = Native.context_get_options(context)

      Native.option_set_is_indented_syntax_src(options, true) if sass?
      Native.option_set_input_path(options, filename) if filename

      callbacks = {}
      Script.setup_custom_functions(options, callbacks)

      status = Native.compile_data_context(data_context)
      css = Native.context_get_output_string(context)
      callbacks = {}

      if status != 0
        puts SassC::Native.context_get_error_message(context)
      end

      Native.delete_data_context(data_context)

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
