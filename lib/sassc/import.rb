module SassC
  class Import
    attr_accessor :path, :source, :source_map_path

    def initialize(path, source: nil, source_map_path: nil)
      @path = path
      @source = source
      @source_map_path = source_map_path
    end
  end
end
