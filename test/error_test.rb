require_relative "test_helper"

module SassC
  class ErrorTest < MiniTest::Test
    def test_first_backtrace_is_sass
      line     = 2
      filename = "app/assets/stylesheets/application.scss"

      begin
        raise SassC::SyntaxError.new(<<-ERROR)
Error: property "padding" must be followed by a ':'
        on line #{line} of #{filename}
>>   padding top: 10px;
   --^
        ERROR
      rescue SassC::SyntaxError => err
        expected = "#{Pathname.getwd.join(filename)}:#{line}"
        assert_equal expected, err.backtrace.first
      end
    end
  end
end
