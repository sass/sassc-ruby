require_relative "test_helper"

class FunctionsTest < SassCTest
  class CustomImporter1 < SassC::Importer
    def imports(path)
      [
        Import.new("#{path}1"),
        Import.new("#{path}2")
      ]
    end
  end

  class CustomImporter2 < SassC::Importer
    def imports(path)

    end
  end

  class CustomImporter3 < SassC::Importer
    def imports(path)
      []
    end
  end

  def around
    within_construct do |construct|
      @construct = construct
      yield
    end

    @construct = nil
  end

  def test_custom_importer_works
    #engine = SassC::Engine.new(data, {
    #  importer: CustomImporter1
    #})
  end

  def test_custom_importer_works_with_no_files

  end

  def test_empty_imports
    engine = SassC::Engine.new("@import 'fake.scss';", {
      importer: CustomImporter3
    })

    assert_equal "", engine.render
  end

  def test_dependency_list
  end
end
