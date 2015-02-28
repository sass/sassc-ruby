require_relative "sass_context"

module SassC
  module Native
    class SassDataContext < FFI::Struct
      STRUCT_LAYOUT = SassContext::STRUCT_LAYOUT + [
        # provided source string
        :source_string, :string
      ]

      layout *STRUCT_LAYOUT

      def self.release(pointer)
        sass_delete_data_context(pointer) unless pointer.null?
      end
    end
  end
end
