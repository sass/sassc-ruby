require_relative "sass_value"

module SassC
  module Native
    class SassCFunctionDescriptor < FFI::Struct
      layout :signature, :string,
             :function, :sass_c_function,
             :cookie, :pointer
    end
  end
end
