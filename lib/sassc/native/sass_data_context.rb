require_relative "sass_options"

module SassC
  module Native
    class SassDataContext < FFI::Struct
      STRUCT_LAYOUT = SassContext::STRUCT_LAYOUT + [
        # provided source string
        :source_string, :string
      ]

      layout *STRUCT_LAYOUT
    end
  end
end
