require_relative "sass_context"

module SassC
  module Native
    class SassFileContext < FFI::Struct
      STRUCT_LAYOUT = SassContext::STRUCT_LAYOUT

      layout *STRUCT_LAYOUT

      def self.release(pointer)
        sass_delete_file_context(pointer) unless pointer.null?
      end
    end
  end
end
