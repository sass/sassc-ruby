require_relative "test_helper"

class EngineTest < SassCTest
  def render(data)
    SassC::Engine.new(data).render
  end

  def test_one_line_comments
    assert_equal <<CSS, render(<<SCSS)
.foo {
  baz: bang; }
CSS
.foo {// bar: baz;}
  baz: bang; //}
}
SCSS
    assert_equal <<CSS, render(<<SCSS)
.foo bar[val="//"] {
  baz: bang; }
CSS
.foo bar[val="//"] {
  baz: bang; //}
}
SCSS
  end

  def test_variables
    assert_equal <<CSS, render(<<SCSS)
blat {
  a: foo; }
CSS
$var: foo;

blat {a: $var}
SCSS

    assert_equal <<CSS, render(<<SCSS)
foo {
  a: 2;
  b: 6; }
CSS
foo {
  $var: 2;
  $another-var: 4;
  a: $var;
  b: $var + $another-var;}
SCSS
  end

  def test_dependency_filenames_are_reported
    within_construct do |construct|
      construct.file("not_included.scss", "$size: 30px;")
      construct.file("import_parent.scss", "$size: 30px;")
      construct.file("import.scss", "@import 'import_parent'; $size: 30px;")
      construct.file("styles.scss", "@import 'import.scss'; .hi { width: $size; }")

      engine = SassC::Engine.new(File.read("styles.scss"))
      engine.render
      deps = engine.dependencies
      filenames = deps.map { |dep| dep.options[:filename] }.sort

      assert_equal ["import.scss", "import_parent.scss"], filenames
    end
  end

  def test_no_dependencies
    engine = SassC::Engine.new("$size: 30px;")
    engine.render
    deps = engine.dependencies
    assert_equal [], deps
  end

  def test_not_rendered_error
    engine = SassC::Engine.new("$size: 30px;")
    assert_raises(SassC::Engine::NotRenderedError) { engine.dependencies }
  end

  def test_load_paths
    within_construct do |c|
      c.directory("included_1")
      c.directory("included_2")

      c.file("included_1/import_parent.scss", "$s: 30px;")
      c.file("included_2/import.scss", "@import 'import_parent'; $size: $s;")
      c.file("styles.scss", "@import 'import.scss'; .hi { width: $size; }")

      assert_equal ".hi {\n  width: 30px; }\n", SassC::Engine.new(
        File.read("styles.scss"),
        load_paths: [ "included_1", "included_2" ]
      ).render
    end
  end

  def test_load_paths_not_configured
    within_construct do |c|
      c.file("included_1/import_parent.scss", "$s: 30px;")
      c.file("included_2/import.scss", "@import 'import_parent'; $size: $s;")
      c.file("styles.scss", "@import 'import.scss'; .hi { width: $size; }")

      assert_raises(SassC::SyntaxError) {
        SassC::Engine.new(File.read("styles.scss")).render
      }
    end
  end
end
