module SassC
  class Importer
    def imports(path)
      # A custom importer must override this method.
      raise NotImplementedError
    end

    def setup(native_options)
      @function = FFI::Function.new(:pointer, [:string, :pointer, :pointer]) do |path, prev, cookie|
        imports = [*imports(path)]
        self.class.imports_to_native(imports)
      end

      callback = SassC::Native.make_importer(@function, nil)
      SassC::Native.option_set_importer(native_options, callback)
    end

    def self.empty_imports
      SassC::Native.make_import_list(0)
    end

    def self.imports_to_native(imports)
      import_list = SassC::Native.make_import_list(imports.size)

      imports.each_with_index do |import, i|
        source = import.source ? native_string(import.source) : nil
        source_map_path = nil

        entry = SassC::Native.make_import_entry(import.path, source, source_map_path)
        SassC::Native.import_set_list_entry(import_list, i, entry)
      end

      import_list
    end

    def self.native_string(string)
      string += "\0"
      data = SassC::Native::LibC.malloc(string.size)
      data.write_string(string)
      data
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
