require "minitest/autorun"
require "minitest/pride"
require "minitest/around/unit"
require "test_construct"

require "sassc"

class SassCTest < MiniTest::Test
  FIXTURE_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "fixtures"))

  def self.test(name, &block)
    define_method("test_#{name.inspect}", &block)
  end

  def fixture(path)
    IO.read(fixture_path(path))
  end

  def fixture_path(path)
    if path.match(FIXTURE_ROOT)
      path
    else
      File.join(FIXTURE_ROOT, path)
    end
  end
end

