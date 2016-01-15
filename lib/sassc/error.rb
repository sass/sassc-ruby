require 'pathname'
require 'sass/error'

module SassC
  class BaseError < StandardError; end
  class NotRenderedError < BaseError; end
  class InvalidStyleError < BaseError; end
  class UnsupportedValue < BaseError; end

  # When dealing with SyntaxErrors,
  # it's important to provide filename and line number information.
  # This will be used in various error reports to users, including backtraces;
  class SyntaxError < BaseError
    def backtrace
      return nil if super.nil?
      sass_backtrace + super
    end

    # The backtrace of the error within Sass files.
    def sass_backtrace
      line_info = message.split("\n")[1]
      return [] unless line_info

      _, line, filename = line_info.match(/on line (\d+) of (.+)/).to_a
      ["#{Pathname.getwd.join(filename)}:#{line}"]
    end
  end
end
