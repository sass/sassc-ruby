module SassC
  class Importer
    def initialize
      raise NotImplementedError
    end

    def imports
      raise NotImplementedError
    end
  end
end
