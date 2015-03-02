module SassC
  class Dependency
    attr_reader :options

    def initialize(filename)
      @options = { filename: filename }
    end

    def self.from_filenames(filenames)
      filenames.map { |f| new(f) }
    end
  end
end
