require 'sass/error'

module SassC
  class BaseError < StandardError; end
  class SyntaxError < BaseError; end
  class NotRenderedError < BaseError; end
  class InvalidStyleError < BaseError; end
  class UnsupportedValue < BaseError; end
end
