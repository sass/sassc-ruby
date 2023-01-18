# frozen_string_literal: true

module SassC
  class ImportHandler
    def initialize(options)
      @importer = if options[:importer]
        options[:importer].new(options)
      else
        nil
      end
    end

    def setup(_native_options)
      Importer.new(@importer) if @importer
    end

    class FileImporter
      class << self
        def resolve_path(path, from_import)
          ext = File.extname(path)
          if ['.sass', '.scss', '.css'].include?(ext)
            if from_import
              result = exactly_one(try_path("#{without_ext(path)}.import#{ext}"))
              return result unless result.nil?
            end
            return exactly_one(try_path(path))
          end

          unless ext.empty?
            if from_import
              result = exactly_one(try_path("#{without_ext(path)}.import#{ext}"))
              return result unless result.nil?
            end
            result = exactly_one(try_path(path))
            return result unless result.nil?
          end

          if from_import
            result = exactly_one(try_path_with_ext("#{path}.import"))
            return result unless result.nil?
          end

          result = exactly_one(try_path_with_ext(path))
          return result unless result.nil?

          try_path_as_dir(path, from_import)
        end

        private

        def try_path_with_ext(path)
          result = try_path("#{path}.sass") + try_path("#{path}.scss")
          result.empty? ? try_path("#{path}.css") : result
        end

        def try_path(path)
          partial = File.join(File.dirname(path), "_#{File.basename(path)}")
          result = []
          result.push(partial) if file_exist?(partial)
          result.push(path) if file_exist?(path)
          result
        end

        def try_path_as_dir(path, from_import)
          return unless dir_exist? path

          if from_import
            result = exactly_one(try_path_with_ext(File.join(path, 'index.import')))
            return result unless result.nil?
          end

          exactly_one(try_path_with_ext(File.join(path, 'index')))
        end

        def exactly_one(paths)
          return if paths.empty?
          return paths.first if paths.length == 1

          raise "It's not clear which file to import. Found:\n#{paths.map { |path| "  #{path}" }.join("\n")}"
        end

        def file_exist?(path)
          File.exist?(path) && File.file?(path)
        end

        def dir_exist?(path)
          File.exist?(path) && File.directory?(path)
        end

        def without_ext(path)
          ext = File.extname(path)
          path.delete_suffix(ext)
        end
      end
    end

    private_constant :FileImporter

    class Importer
      def initialize(importer)
        @importer = importer

        @canonical_urls = {}
        @id = 0
        @importer_results = {}
        @parent_urls = [URL.path_to_file_url(File.absolute_path(@importer.options[:filename] || 'stdin'))]
      end

      def canonicalize(url, from_import:)
        if url.start_with?(Protocol::IMPORT)
          canonical_url = @canonical_urls.delete(url.delete_prefix(Protocol::IMPORT))
          unless @importer_results.key?(canonical_url)
            canonical_url = resolve_file_url(canonical_url, @parent_urls.last, from_import)
          end
          @parent_urls.push(canonical_url)
          canonical_url
        elsif url.start_with?(Protocol::FILE)
          path = URL.parse(url).route_from(@parent_urls.last).to_s
          parent_path = URL.file_url_to_path(@parent_urls.last)

          imports = @importer.imports(path, parent_path)
          imports = [SassC::Importer::Import.new(path)] if imports.nil?
          imports = [imports] unless imports.is_a?(Array)
          imports.each do |import|
            import.path = File.absolute_path(import.path, File.dirname(parent_path))
          end

          canonical_url = "#{Protocol::IMPORT}#{next_id}"
          @importer_results[canonical_url] = imports_to_native(imports)
          canonical_url
        elsif url.start_with?(Protocol::LOADED)
          canonical_url = Protocol::LOADED
          @parent_urls.pop
          canonical_url
        end
      end

      def load(canonical_url)
        if @importer_results.key?(canonical_url)
          @importer_results.delete(canonical_url)
        elsif canonical_url.start_with?(Protocol::FILE)
          path = URL.file_url_to_path(canonical_url)
          {
            contents: File.read(path),
            syntax: syntax(path),
            source_map_url: canonical_url
          }
        elsif canonical_url.start_with?(Protocol::LOADED)
          {
            contents: '',
            syntax: :scss
          }
        end
      end

      private

      def load_paths
        @load_paths ||= (@importer.options[:load_paths] || []) + SassC.load_paths
      end

      def resolve_file_url(url, parent_url, from_import)
        path = URL.parse(url).route_from(parent_url).to_s
        parent_path = URL.file_url_to_path(parent_url)
        [File.dirname(parent_path)].concat(load_paths).each do |load_path|
          resolved = FileImporter.resolve_path(File.absolute_path(path, load_path), from_import)
          return URL.path_to_file_url(resolved) unless resolved.nil?
        end
        nil
      end

      def syntax(path)
        case File.extname(path)
        when '.sass'
          :indented
        when '.css'
          :css
        else
          :scss
        end
      end

      def imports_to_native(imports)
        {
          contents: imports.flat_map do |import|
            id = next_id
            canonical_url = URL.path_to_file_url(import.path)
            @canonical_urls[id] = canonical_url
            if import.source
              @importer_results[canonical_url] = if import.source.is_a?(Hash)
                                                   {
                                                     contents: import.source[:contents],
                                                     syntax: import.source[:syntax],
                                                     source_map_url: canonical_url
                                                   }
                                                 else
                                                   {
                                                     contents: import.source,
                                                     syntax: syntax(import.path),
                                                     source_map_url: canonical_url
                                                   }
                                                 end
            end
            [
              "@import \"#{Protocol::IMPORT}#{id}\";",
              "@import \"#{Protocol::LOADED}#{id}\";"
            ]
          end.join("\n"),
          syntax: :scss
        }
      end

      def next_id
        id = @id
        @id = id.next
        id.to_s
      end
    end

    private_constant :Importer
  end
end
