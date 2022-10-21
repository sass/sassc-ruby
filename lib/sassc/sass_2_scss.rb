# frozen_string_literal: true

module SassC
  class Sass2Scss
    def self.convert(sass)
      {
        contents: sass,
        syntax: :indented
      }
    end
  end
end
