module SassC
  class Importer
    def self.setup(native_options)
      @funct = FFI::Function.new(:pointer, [:pointer, :pointer, :pointer]) do |path, prev, cookie|
        importer = new
        imports = importer.imports(path)

        if imports.empty?
          empty_imports
        else
          imports_to_native(imports)
        end
      end

      callback = SassC::Native.make_importer(@funct, nil)
      SassC::Native.option_set_importer(native_options, callback)
    end

    def self.empty_imports
      list = SassC::Native.make_import_list(0)

      #data = FFI::MemoryPointer.from_string("")

      #entry0 = SassC::Native.make_import_entry("", data, nil)
      #SassC::Native.import_set_list_entry(list, 0, entry0)
      list
      #SassC::Native.import_set_list_entry(list, 1, entry1)
    end

    def self.imports_to_native
      #list = SassC::Native.make_import_list(2)
      #random_thing = FFI::MemoryPointer.from_string("$var: 5px;")
      #entry0 = SassC::Native.make_import_entry("fake_includ.scss", random_thing, nil)
      #entry1 = SassC::Native.make_import_entry("not_included.scss", nil, nil)
      #SassC::Native.import_set_list_entry(list, 0, entry0)
      #SassC::Native.import_set_list_entry(list, 1, entry1)
      #list
    end

    def initialize
    end

    def imports(path)
      raise NotImplementedError
    end

    class Import
      attr_accessor :path, :source, :source_map_path

      def initialize(path, source: nil, source_map_path: nil)
        @path = path
        @source = source
        @source_map_path = source_map_path
      end
    end
  end
end
