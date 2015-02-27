require "ffi"

module SassC
  module Native
    extend FFI::Library
    ffi_lib 'ext/libsass/lib/libsass.so'

    attach_function :version, :libsass_version, [], :string
  end
end

require_relative "native/sass_input_style"
require_relative "native/string_list"
require_relative "native/sass_options"
require_relative "native/sass_context"
require_relative "native/sass_file_context"
require_relative "native/sass_data_context"
