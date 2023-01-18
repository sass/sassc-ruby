# frozen_string_literal: true

# # A module containing various useful functions.
module SassC::Util

  extend self

  # Whether or not this is running on Windows.
  #
  # @return [Boolean]
  def windows?
    return @windows if defined?(@windows)
    @windows = RbConfig::CONFIG['host_os'].match?(/mswin|windows|mingw/i)
  end
end
