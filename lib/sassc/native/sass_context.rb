require_relative "sass_options"

module SassC
  module Native
    class SassContext < FFI::Struct
      STRUCT_LAYOUT = SassOptions::STRUCT_LAYOUT + [
        # store context type info
        :type, SassInputStyle,

        # generated output data
        :output_string, :string,

        # generated source map json
        :source_map_string, :string,

        # error status
        :error_status, :int,
        :error_json, :string,
        :error_message, :string,

        # error position
        :error_file, :string,
        :error_line, :size_t,
        :error_column, :size_t,

        # TODO: is this correct?
        #
        # report imported files
        # char** included_files;
        :included_files, :pointer
      ]

      layout *STRUCT_LAYOUT
    end
  end
end
