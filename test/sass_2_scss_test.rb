# frozen_string_literal: true

require_relative "test_helper"

module SassC
  class Sass2ScssTest < MiniTest::Test
    def test_compact_output
      exp = { contents: ".blat\n  color: red\n",
              syntax: :indented }
      assert_equal exp, Sass2Scss.convert(<<SASS)
.blat
  color: red
SASS
    end
  end
end
