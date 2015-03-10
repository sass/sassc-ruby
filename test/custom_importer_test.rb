require_relative "test_helper"

class FunctionsTest < SassCTest
  class CustomImporter < SassC::Importer
    def imports(path, parent_path)
      if path =~ /styles/
        [
          Import.new("#{path}1.scss", source: "$var1: #000;"),
          Import.new("#{path}2.scss")
        ]
      else
        Import.new(path)
      end
    end
  end

  class NoFilesImporter < SassC::Importer
    def imports(path, parent_path)
      []
    end
  end

  class OptionsImporter < SassC::Importer
    def imports(path, parent_path)
      Import.new("name.scss", source: options[:custom_option_source])
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
    @construct.file("styles2.scss", ".hi { color: $var1; }")
    @construct.file("fonts.scss", ".font { color: $var1; }")

    data = <<SCSS
@import "styles";
@import "fonts";
SCSS

    engine = SassC::Engine.new(data, {
      importer: CustomImporter
    })

    assert_equal <<CSS, engine.render
.hi {
  color: #000; }

.font {
  color: #000; }
CSS
  end

  def test_dependency_list
    @construct.file("styles2.scss", ".hi { color: $var1; }")
    @construct.file("fonts.scss", ".font { color: $var1; }")

    data = <<SCSS
@import "styles";
@import "fonts";
SCSS

    engine = SassC::Engine.new(data, {
      importer: CustomImporter
    })
    engine.render

    dependencies = engine.dependencies.map(&:options).map { |o| o[:filename] }

    # TODO: this behavior is kind of weird (styles1.scss is not included)
    # not sure why.

    assert_equal [
      "fonts.scss",
      "styles",
      "styles2.scss"
    ], dependencies
  end

  def test_custom_importer_works_with_no_files
    engine = SassC::Engine.new("@import 'fake.scss';", {
      importer: NoFilesImporter
    })

    assert_equal "", engine.render
  end

  def test_custom_importer_can_access_sassc_options
    engine = SassC::Engine.new("@import 'fake.scss';", {
      importer: OptionsImporter,
      custom_option_source: ".test { width: 30px; }"
    })

    assert_equal <<CSS, engine.render
.test {
  width: 30px; }
CSS
  end

  def test_parent_path_is_accessible
    skip "TBD"
  end
end
