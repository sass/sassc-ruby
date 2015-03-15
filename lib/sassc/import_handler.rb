module SassC
  class ImportHandler
    def initialize(options)
      @importer = if options[:importer]
        options[:importer].new(options)
      else
        nil
      end
    end

    def setup(native_options)
      return unless @importer

      callback = Native.make_importer(import_function, nil)
      Native.option_set_importer(native_options, callback)
    end

    private

    def import_function
      @import_function ||= FFI::Function.new(:pointer, [:string, :string, :pointer]) do |path, parent_path, cookie|
        imports = [*@importer.imports(path, parent_path)]
        imports_to_native(imports)
      end
    end

    def imports_to_native(imports)
      import_list = Native.make_import_list(imports.size)

      imports.each_with_index do |import, i|
        source = import.source ? Native.native_string(import.source) : nil
        source_map_path = nil

        entry = Native.make_import_entry(import.path, source, source_map_path)
        Native.import_set_list_entry(import_list, i, entry)
      end

      import_list
    end
  end
end
