require_relative "sass_input_style"
require_relative "string_list"

module SassC
  module Native
    class SassOptions < FFI::Struct
      STRUCT_LAYOUT = [
        # Precision for fractional numbers
        :precision, :int32,

        # Output style for the generated css code
        # A value from above SASS_STYLE_* constants
        :output_style, SassInputStyle,

        # Emit comments in the generated CSS indicating
        # the corresponding source line.
        :source_comments, :bool,

        # embed sourceMappingUrl as data uri
        :source_map_embed, :bool,

        # embed include contents in maps
        :source_map_contents, :bool,

        # Disable sourceMappingUrl in css output
        :omit_source_map_url, :bool,

        # Treat source_string as sass (as opposed to scss)
        :is_indented_syntax_src, :bool,

        # The input path is used for source map
        # generation. It can be used to define
        # something with string compilation or to
        # overload the input file path. It is
        # set to "stdin" for data contexts and
        # to the input file on file contexts.
        :input_path, :string,

        # The output path is used for source map
        # generation. Libsass will not write to
        # this file, it is just used to create
        # information in source-maps etc.
        :output_path, :string,

        # For the image-url Sass function
        :image_path, :string,

        # Colon-separated list of paths
        # Semicolon-separated on Windows
        # Maybe use array interface instead?
        :include_path, :string,

        # Include path (linked string list)
        :include_paths, StringList.ptr,

        # Path to source map file
        # Enables source map generation
        # Used to create sourceMappingUrl
        :source_map_file, :string,

        # Custom functions that can be called from sccs code
        Sass_C_Function_List c_functions;

        # Callback to overload imports
        Sass_C_Import_Callback importer;
      ]

      layout *STRUCT_LAYOUT
    end
  end
end
