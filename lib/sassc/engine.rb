module SassC
  class Engine
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

      status = Script.setup_custom_functions(options) do
        Native.compile_data_context(data_context)
      end

      css = Native.context_get_output_string(context)

      if status != 0
        puts SassC::Native.context_get_error_message(context)
      end

      @dependencies = Native.context_get_included_files(context)

      Native.delete_data_context(data_context)

      return css unless quiet?
    end

    def dependencies
      return [] unless @dependencies
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
  end
end
