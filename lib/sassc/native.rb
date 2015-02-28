require "ffi"

module SassC
  module Native
    extend FFI::Library
    ffi_lib 'ext/libsass/lib/libsass.so'

    require_relative "native/sass_value"
    callback :sass_c_function, [:pointer, :pointer], :pointer

    require_relative "native/sass_input_style"
    require_relative "native/sass_output_style"
    require_relative "native/string_list"
    require_relative "native/sass_options"
    require_relative "native/sass_context"
    require_relative "native/sass_file_context"
    require_relative "native/sass_data_context"
    require_relative "native/sass_c_function_descriptor"

    # Remove the redundant "sass_" from the beginning of every method name
    def self.attach_function(*args)
      super if args.size != 3

      if args[0] =~ /^sass_/
        args.unshift args[0].to_s.sub(/^sass_/, "")
      end

      super(*args)
    end

    # https://github.com/ffi/ffi/wiki/Examples#array-of-strings
    def self.return_string_array(ptr)
      ptr.read_pointer.null? ? [] : ptr.get_array_of_string(0).compact
    end

    typedef :pointer, :sass_options_ptr
    typedef :pointer, :sass_context_ptr
    typedef :pointer, :sass_file_context_ptr
    typedef :pointer, :sass_data_context_ptr

    attach_function :version, :libsass_version, [], :string

    # Create and initialize an option struct
    # ADDAPI struct Sass_Options* ADDCALL sass_make_options (void);
    attach_function :sass_make_options, [], :sass_options_ptr

    # Create and initialize a specific context
    # ADDAPI struct Sass_File_Context* ADDCALL sass_make_file_context (const char* input_path);
    # ADDAPI struct Sass_Data_Context* ADDCALL sass_make_data_context (char* source_string);
    attach_function :sass_make_file_context, [:string], :sass_file_context_ptr
    attach_function :sass_make_data_context, [:string], :sass_data_context_ptr

    # Call the compilation step for the specific context
    # ADDAPI int ADDCALL sass_compile_file_context (struct Sass_File_Context* ctx);
    # ADDAPI int ADDCALL sass_compile_data_context (struct Sass_Data_Context* ctx);
    attach_function :sass_compile_file_context, [:sass_file_context_ptr], :int
    attach_function :sass_compile_data_context, [:sass_data_context_ptr], :int

    # Create a sass compiler instance for more control
    # ADDAPI struct Sass_Compiler* ADDCALL sass_make_file_compiler (struct Sass_File_Context* file_ctx);
    # ADDAPI struct Sass_Compiler* ADDCALL sass_make_data_compiler (struct Sass_Data_Context* data_ctx);

    # Execute the different compilation steps individually
    # Usefull if you only want to query the included files
    # ADDAPI int ADDCALL sass_compiler_parse(struct Sass_Compiler* compiler);
    # ADDAPI int ADDCALL sass_compiler_execute(struct Sass_Compiler* compiler);

    # Release all memory allocated with the compiler
    # This does _not_ include any contexts or options
    # ADDAPI void ADDCALL sass_delete_compiler(struct Sass_Compiler* compiler);

    # Release all memory allocated and also ourself
    # ADDAPI void ADDCALL sass_delete_file_context (struct Sass_File_Context* ctx);
    # ADDAPI void ADDCALL sass_delete_data_context (struct Sass_Data_Context* ctx);
    attach_function :sass_delete_file_context, [:sass_file_context_ptr], :void
    attach_function :sass_delete_data_context, [:sass_data_context_ptr], :void

    # Getters for context from specific implementation
    # ADDAPI struct Sass_Context* ADDCALL sass_file_context_get_context (struct Sass_File_Context* file_ctx);
    # ADDAPI struct Sass_Context* ADDCALL sass_data_context_get_context (struct Sass_Data_Context* data_ctx);
    attach_function :sass_file_context_get_context, [:sass_file_context_ptr], :sass_context_ptr
    attach_function :sass_data_context_get_context, [:sass_data_context_ptr], :sass_context_ptr

    # Getters for context options from Sass_Context
    # ADDAPI struct Sass_Options* ADDCALL sass_context_get_options (struct Sass_Context* ctx);
    # ADDAPI struct Sass_Options* ADDCALL sass_file_context_get_options (struct Sass_File_Context* file_ctx);
    # ADDAPI struct Sass_Options* ADDCALL sass_data_context_get_options (struct Sass_Data_Context* data_ctx);
    # ADDAPI void ADDCALL sass_file_context_set_options (struct Sass_File_Context* file_ctx, struct Sass_Options* opt);
    # ADDAPI void ADDCALL sass_data_context_set_options (struct Sass_Data_Context* data_ctx, struct Sass_Options* opt);
    attach_function :sass_context_get_options, [:sass_context_ptr], :sass_options_ptr
    attach_function :sass_file_context_get_options, [:sass_file_context_ptr], :sass_options_ptr
    attach_function :sass_data_context_get_options, [:sass_data_context_ptr], :sass_options_ptr
    attach_function :sass_file_context_set_options, [:sass_file_context_ptr, :sass_options_ptr], :void
    attach_function :sass_data_context_set_options, [:sass_data_context_ptr, :sass_options_ptr], :void

    # Getters for options
    # ADDAPI int ADDCALL sass_option_get_precision (struct Sass_Options* options);
    # ADDAPI enum Sass_Output_Style ADDCALL sass_option_get_output_style (struct Sass_Options* options);
    # ADDAPI bool ADDCALL sass_option_get_source_comments (struct Sass_Options* options);
    # ADDAPI bool ADDCALL sass_option_get_source_map_embed (struct Sass_Options* options);
    # ADDAPI bool ADDCALL sass_option_get_source_map_contents (struct Sass_Options* options);
    # ADDAPI bool ADDCALL sass_option_get_omit_source_map_url (struct Sass_Options* options);
    # ADDAPI bool ADDCALL sass_option_get_is_indented_syntax_src (struct Sass_Options* options);
    # ADDAPI const char* ADDCALL sass_option_get_input_path (struct Sass_Options* options);
    # ADDAPI const char* ADDCALL sass_option_get_output_path (struct Sass_Options* options);
    # ADDAPI const char* ADDCALL sass_option_get_image_path (struct Sass_Options* options);
    # ADDAPI const char* ADDCALL sass_option_get_include_path (struct Sass_Options* options);
    # ADDAPI const char* ADDCALL sass_option_get_source_map_file (struct Sass_Options* options);
    attach_function :sass_option_get_precision, [:sass_options_ptr], :int
    attach_function :sass_option_get_output_style, [:sass_options_ptr], SassOutputStyle
    attach_function :sass_option_get_source_comments, [:sass_options_ptr], :bool
    attach_function :sass_option_get_source_map_embed, [:sass_options_ptr], :bool
    attach_function :sass_option_get_source_map_contents, [:sass_options_ptr], :bool
    attach_function :sass_option_get_omit_source_map_url, [:sass_options_ptr], :bool
    attach_function :sass_option_get_is_indented_syntax_src, [:sass_options_ptr], :bool
    attach_function :sass_option_get_input_path, [:sass_options_ptr], :string
    attach_function :sass_option_get_output_path, [:sass_options_ptr], :string
    attach_function :sass_option_get_image_path, [:sass_options_ptr], :string
    attach_function :sass_option_get_include_path, [:sass_options_ptr], :string
    attach_function :sass_option_get_source_map_file, [:sass_options_ptr], :string
    # ADDAPI Sass_C_Function_List ADDCALL sass_option_get_c_functions (struct Sass_Options* options);
    # ADDAPI Sass_C_Import_Callback ADDCALL sass_option_get_importer (struct Sass_Options* options);

    # Setters for options
    # ADDAPI void ADDCALL sass_option_set_precision (struct Sass_Options* options, int precision);
    # ADDAPI void ADDCALL sass_option_set_output_style (struct Sass_Options* options, enum Sass_Output_Style output_style);
    # ADDAPI void ADDCALL sass_option_set_source_comments (struct Sass_Options* options, bool source_comments);
    # ADDAPI void ADDCALL sass_option_set_source_map_embed (struct Sass_Options* options, bool source_map_embed);
    # ADDAPI void ADDCALL sass_option_set_source_map_contents (struct Sass_Options* options, bool source_map_contents);
    # ADDAPI void ADDCALL sass_option_set_omit_source_map_url (struct Sass_Options* options, bool omit_source_map_url);
    # ADDAPI void ADDCALL sass_option_set_is_indented_syntax_src (struct Sass_Options* options, bool is_indented_syntax_src);
    # ADDAPI void ADDCALL sass_option_set_input_path (struct Sass_Options* options, const char* input_path);
    # ADDAPI void ADDCALL sass_option_set_output_path (struct Sass_Options* options, const char* output_path);
    # ADDAPI void ADDCALL sass_option_set_image_path (struct Sass_Options* options, const char* image_path);
    # ADDAPI void ADDCALL sass_option_set_include_path (struct Sass_Options* options, const char* include_path);
    # ADDAPI void ADDCALL sass_option_set_source_map_file (struct Sass_Options* options, const char* source_map_file);
    # ADDAPI void ADDCALL sass_option_set_c_functions (struct Sass_Options* options, Sass_C_Function_List c_functions);
    attach_function :sass_option_set_precision, [:sass_options_ptr, :int], :void
    attach_function :sass_option_set_output_style, [:sass_options_ptr, SassOutputStyle], :void
    attach_function :sass_option_set_source_comments, [:sass_options_ptr, :bool], :void
    attach_function :sass_option_set_source_map_embed, [:sass_options_ptr, :bool], :void
    attach_function :sass_option_set_source_map_contents, [:sass_options_ptr, :bool], :void
    attach_function :sass_option_set_omit_source_map_url, [:sass_options_ptr, :bool], :void
    attach_function :sass_option_set_is_indented_syntax_src, [:sass_options_ptr, :bool], :void
    attach_function :sass_option_set_input_path, [:sass_options_ptr, :string], :void
    attach_function :sass_option_set_output_path, [:sass_options_ptr, :string], :void
    attach_function :sass_option_set_image_path, [:sass_options_ptr, :string], :void
    attach_function :sass_option_set_include_path, [:sass_options_ptr, :string], :void
    attach_function :sass_option_set_source_map_file, [:sass_options_ptr, :string], :void
    attach_function :sass_option_set_c_functions, [:sass_options_ptr, :pointer], :void
    # ADDAPI void ADDCALL sass_option_set_importer (struct Sass_Options* options, Sass_C_Import_Callback importer);

    # Getter for context
    # ADDAPI const char* ADDCALL sass_context_get_output_string (struct Sass_Context* ctx);
    # ADDAPI int ADDCALL sass_context_get_error_status (struct Sass_Context* ctx);
    # ADDAPI const char* ADDCALL sass_context_get_error_json (struct Sass_Context* ctx);
    # ADDAPI const char* ADDCALL sass_context_get_error_message (struct Sass_Context* ctx);
    # ADDAPI const char* ADDCALL sass_context_get_error_file (struct Sass_Context* ctx);
    # ADDAPI size_t ADDCALL sass_context_get_error_line (struct Sass_Context* ctx);
    # ADDAPI size_t ADDCALL sass_context_get_error_column (struct Sass_Context* ctx);
    # ADDAPI const char* ADDCALL sass_context_get_source_map_string (struct Sass_Context* ctx);
    # ADDAPI char** ADDCALL sass_context_get_included_files (struct Sass_Context* ctx);
    attach_function :sass_context_get_output_string, [:sass_context_ptr], :string
    attach_function :sass_context_get_error_status, [:sass_context_ptr], :int
    attach_function :sass_context_get_error_json, [:sass_context_ptr], :string
    attach_function :sass_context_get_error_message, [:sass_context_ptr], :string
    attach_function :sass_context_get_error_file, [:sass_context_ptr], :string
    attach_function :sass_context_get_error_line, [:sass_context_ptr], :size_t
    attach_function :sass_context_get_error_column, [:sass_context_ptr], :size_t
    attach_function :sass_context_get_source_map_string, [:sass_context_ptr], :string
    attach_function :_context_get_included_files, :sass_context_get_included_files, [:sass_context_ptr], :pointer

    def self.context_get_included_files(*args)
      return_string_array _context_get_included_files(*args)
    end

    # Creators for sass function list and function descriptors
    # ADDAPI Sass_C_Function_List ADDCALL sass_make_function_list (size_t length);
    # ADDAPI Sass_C_Function_Callback ADDCALL sass_make_function (const char* signature, Sass_C_Function fn, void* cookie);
    attach_function :sass_make_function_list, [:size_t], :pointer
    attach_function :sass_make_function, [:string, :sass_c_function, :pointer], :pointer

    # Setters and getters for callbacks on function lists
    # ADDAPI Sass_C_Function_Callback ADDCALL sass_function_get_list_entry(Sass_C_Function_List list, size_t pos);
    # ADDAPI void ADDCALL sass_function_set_list_entry(Sass_C_Function_List list, size_t pos, Sass_C_Function_Callback cb);
    attach_function :sass_function_set_list_entry, [:pointer, :size_t, :pointer], :void


    # ADDAPI union Sass_Value* ADDCALL sass_make_number  (double val, const char* unit);
    attach_function :sass_make_number, [:double, :string], :pointer
    attach_function :sass_make_string, [:string], :pointer


    #callback :sass_c_function, [SassValue.ptr, :pointer], SassValue.ptr
    Callback = FFI::Function.new(:pointer, [:pointer, :pointer]) do |s_args, cookie|
      return make_string("px").value
    end
  end
end
