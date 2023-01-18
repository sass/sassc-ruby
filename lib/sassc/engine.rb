# frozen_string_literal: true

require_relative "error"

module SassC
  class Engine
    OUTPUT_STYLES = %i[
      sass_style_nested
      sass_style_expanded
      sass_style_compact
      sass_style_compressed
    ]

    attr_reader :template, :options

    def initialize(template, options = {})
      @template = template
      @options = options
      @functions = options.fetch(:functions, Script::Functions)
    end

    def render
      return @template.dup if @template.empty?

      result = ::Sass.compile_string(
        @template,
        importer: import_handler.setup(nil),
        load_paths: load_paths,
        syntax: syntax,
        url: file_url,

        charset: @options.fetch(:charset, true),
        source_map: source_map_embed? || !source_map_file.nil?,
        source_map_include_sources: source_map_contents?,
        style: output_style,

        functions: functions_handler.setup(nil, functions: @functions),
        importers: @options.fetch(:importers, []),

        alert_ascii: @options.fetch(:alert_ascii, false),
        alert_color: @options.fetch(:alert_color, nil),
        logger: @options.fetch(:logger, nil),
        quiet_deps: @options.fetch(:quiet_deps, false),
        verbose: @options.fetch(:verbose, false)
      )

      @dependencies = result.loaded_urls
                            .filter { |url| url.start_with?(Protocol::FILE) && url != file_url }
                            .map { |url| URL.file_url_to_path(url) }
      @source_map = post_process_source_map(result.source_map)

      return post_process_css(result.css) unless quiet?
    rescue ::Sass::CompileError => e
      line = e.span&.start&.line
      line += 1 unless line.nil?
      url = e.span&.url
      path = (URL.parse(url).route_from(URL.path_to_file_url("#{Dir.pwd}/")) if url&.start_with?(Protocol::FILE))
      raise SyntaxError.new(e.full_message, filename: path, line: line)
    end

    def dependencies
      raise NotRenderedError unless @dependencies
      Dependency.from_filenames(@dependencies)
    end

    def source_map
      raise NotRenderedError unless @source_map
      @source_map
    end

    def filename
      @options[:filename]
    end

    private

    def quiet?
      @options[:quiet]
    end

    def precision
      @options[:precision]
    end

    def sass?
      @options[:syntax] && @options[:syntax].to_sym == :sass
    end

    def line_comments?
      @options[:line_comments]
    end

    def source_map_embed?
      @options[:source_map_embed]
    end

    def source_map_contents?
      @options[:source_map_contents]
    end

    def omit_source_map_url?
      @options[:omit_source_map_url]
    end

    def source_map_file
      @options[:source_map_file]
    end

    def validate_source_map_path?
      @options.fetch(:validate_source_map_path, true)
    end

    def import_handler
      @import_handler ||= ImportHandler.new(@options)
    end

    def functions_handler
      @functions_handler = FunctionsHandler.new(@options)
    end

    def file_url
      @file_url ||= URL.path_to_file_url(File.absolute_path(filename || 'stdin'))
    end

    def output_path
      @output_path ||= @options.fetch(
        :output_path,
        ("#{filename.delete_suffix(File.extname(filename))}.css" if filename)
      )
    end

    def output_url
      @output_url ||= (URL.path_to_file_url(File.absolute_path(output_path)) if output_path)
    end

    def source_map_file_url
      return unless source_map_file
      @source_map_file_url ||=
        if validate_source_map_path?
          URL.path_to_file_url(File.absolute_path(source_map_file))
        else
          source_map_file
        end
    end

    def output_style_enum
      @output_style_enum ||= Native::SassOutputStyle[output_style]
    end

    def output_style
      @output_style ||= begin
                          style = @options.fetch(:style, :sass_style_nested).to_s
                          style = "sass_style_#{style}" unless style.include?('sass_style_')
                          raise InvalidStyleError unless OUTPUT_STYLES.include?(style.to_sym)

                          style = style.delete_prefix('sass_style_').to_sym
                          case style
                          when :nested, :compact
                            :expanded
                          else
                            style
                          end
                        end
    end

    def syntax
      syntax = @options.fetch(:syntax, :scss)
      syntax = :indented if syntax.to_sym == :sass
      syntax
    end

    def load_paths
      @load_paths ||= if @options[:importer].nil?
                        (@options[:load_paths] || []) + SassC.load_paths
                      else
                        []
                      end
    end

    def post_process_source_map(source_map)
      return unless source_map

      url = URL.parse(source_map_file_url || file_url)
      data = JSON.parse(source_map)
      data["file"] = if validate_source_map_path?
        URL.parse(output_url).route_from(url).to_s
      else
        output_url
      end
      data["sources"].map! do |source|
        if source.start_with?(Protocol::FILE) && validate_source_map_path?
          URL.parse(source).route_from(url).to_s
        else
          source
        end
      end

      JSON.generate(data)
    end

    def post_process_css(css)
      css += "\n" unless css.empty?
      unless @source_map.nil? || omit_source_map_url?
        url = URL.parse(output_url || file_url)
        source_mapping_url =
          if source_map_embed?
            "data:application/json;base64,#{Base64.strict_encode64(@source_map)}"
          else
            if validate_source_map_path?
              URL.parse(source_map_file_url).route_from(url).to_s
            else
              source_map_file_url
            end
        css += "\n/*# sourceMappingURL=#{source_mapping_url} */"
      end
      css
    end
  end
end
