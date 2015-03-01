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
end
