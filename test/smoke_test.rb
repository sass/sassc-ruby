require_relative "test_helper"
require "sassc"

module SmokeTest
  SAMPLE_SASS_STRING = "$size: 30px; .hi { width: $size; }"
  SAMPLE_CSS_OUTPUT = ".hi {\n  width: 30px; }\n"
  BAD_SASS_STRING = "$size = 30px;"

  class General < MiniTest::Test
    def test_it_reports_the_libsass_version
      assert_equal "3.1.0", SassC::Native.version
    end
  end

  class DataContext < MiniTest::Test
    def test_compile_status_is_zero_when_successful
      data_context = SassC::Native.sass_make_data_context(SAMPLE_SASS_STRING)
      context = SassC::Native.sass_data_context_get_context(data_context)

      status = SassC::Native.sass_compile_data_context(data_context)
      assert_equal 0, status

      status = SassC::Native.sass_context_get_error_status(context)
      assert_equal 0, status
    end

    def test_compiled_css_is_correct
      data_context = SassC::Native.sass_make_data_context(SAMPLE_SASS_STRING)
      context = SassC::Native.sass_data_context_get_context(data_context)
      SassC::Native.sass_compile_data_context(data_context)

      css = SassC::Native.sass_context_get_output_string(context)
      assert_equal SAMPLE_CSS_OUTPUT, css
    end

    def test_compile_status_is_one_if_failed
      data_context = SassC::Native.sass_make_data_context(BAD_SASS_STRING)
      context = SassC::Native.sass_data_context_get_context(data_context)

      status = SassC::Native.sass_compile_data_context(data_context)
      assert_equal 1, status

      status = SassC::Native.sass_context_get_error_status(context)
      assert_equal 1, status
    end

    def test_failed_compile_gives_error_message
    end
  end

  class FileContext < MiniTest::Test
    include TestConstruct::Helpers

    def around
      within_construct do |construct|
        construct.file('foo.txt')
        yield
      end
    end

    def test_compile_status_is_zero_when_successful
      assert File.exist?('foo.txt')

      file_context = SassC::Native.sass_make_file_context("foo.txt")
      context = SassC::Native.sass_file_context_get_context(file_context)

      status = SassC::Native.sass_compile_file_context(file_context)
      assert_equal 0, status
    end
  end
end

    #context = SassC::Native.sass_data_context_get_context(data_context)
    #options = SassC::Native.sass_context_get_options(context)
# if status == 0
#   puts SassC::Native.sass_context_get_output_string(context)
#   puts data_context[:source_string]
# else
#   puts "error"
#   puts SassC::Native.sass_context_get_error_message(context)
# end
