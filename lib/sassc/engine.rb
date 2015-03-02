module SassC
  class Engine
    class NotRenderedError < StandardError; end

    def initialize(template, options = {})
      @template = template
      @options = options
    end

    def render
      data_context = Native.make_data_context(@template)
      context = Native.data_context_get_context(data_context)
      options = Native.context_get_options(context)

      Native.option_set_is_indented_syntax_src(options, true) if sass?
      Native.option_set_input_path(options, filename) if filename
      Native.option_set_include_path(options, load_paths)

      status = Script.setup_custom_functions(options) do
        Native.compile_data_context(data_context)
      end

      css = Native.context_get_output_string(context)

      if status != 0
        message = SassC::Native.context_get_error_message(context)
        raise SyntaxError.new(message)
      end

      @dependencies = Native.context_get_included_files(context)

      Native.delete_data_context(data_context)

      return css unless quiet?
    end

    def dependencies
      raise NotRenderedError unless @dependencies
      Dependency.from_filenames(@dependencies)
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

    def load_paths
      paths = @options[:load_paths]
      paths.join(":") if paths
    end
  end
end
