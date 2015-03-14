module SassC
  class Importer
    attr_reader :options

    def imports(path, parent_path)
      # A custom importer must override this method.
      raise NotImplementedError
    end

    def setup(native_options)
      @function = FFI::Function.new(:pointer, [:string, :string, :pointer]) do |path, parent_path, cookie|
        imports = [*imports(path, parent_path)]
        self.class.imports_to_native(imports)
      end

      callback = Native.make_importer(@function, nil)
      Native.option_set_importer(native_options, callback)
    end

    def initialize(options)
      @options = options
    end

    def self.imports_to_native(imports)
      import_list = Native.make_import_list(imports.size)

      imports.each_with_index do |import, i|
        source = import.source ? Native.native_string(import.source) : nil
        source_map_path = nil

        entry = Native.make_import_entry(import.path, source, source_map_path)
        Native.import_set_list_entry(import_list, i, entry)
      end

      import_list
    end

    class Import
      attr_accessor :path, :source, :source_map_path

      def initialize(path, source: nil, source_map_path: nil)
        @path = path
        @source = source
        @source_map_path = source_map_path
      end

      def to_s
        "Import: #{path} #{source} #{source_map_path}"
      end
    end
  end
end
