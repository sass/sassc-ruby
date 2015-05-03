module SassC
  module Native
    # Creators for sass function list and function descriptors
    # ADDAPI Sass_C_Function_List ADDCALL sass_make_function_list (size_t length);
    # ADDAPI Sass_C_Function_Callback ADDCALL sass_make_function (const char* signature, Sass_C_Function fn, void* cookie);
    attach_function :sass_make_function_list, [:size_t], :sass_c_function_list_ptr
    attach_function :sass_make_function, [:string, :sass_c_function, :pointer], :sass_c_function_callback_ptr

    # Setters and getters for callbacks on function lists
    # ADDAPI Sass_C_Function_Callback ADDCALL sass_function_get_list_entry(Sass_C_Function_List list, size_t pos);
    # ADDAPI void ADDCALL sass_function_set_list_entry(Sass_C_Function_List list, size_t pos, Sass_C_Function_Callback cb);
    attach_function :sass_function_get_list_entry, [:sass_c_function_list_ptr, :size_t], :sass_c_function_callback_ptr
    attach_function :sass_function_set_list_entry, [:sass_c_function_list_ptr, :size_t, :sass_c_function_callback_ptr], :void

    # ADDAPI union Sass_Value* ADDCALL sass_make_number  (double val, const char* unit);
    attach_function :sass_make_number, [:double, :string], :sass_value_ptr
    attach_function :sass_make_string, [:string], :sass_value_ptr


    # ADDAPI enum Sass_Tag ADDCALL sass_value_get_tag (const union Sass_Value* v);
    attach_function :sass_value_get_tag, [:sass_value_ptr], SassTag

    # ADDAPI const char* ADDCALL sass_string_get_value (const union Sass_Value* v);
    attach_function :sass_string_get_value, [:sass_value_ptr], :string

    # ADDAPI size_t ADDCALL sass_list_get_length(const union Sass_Value* v)
    # ADDAPI union Sass_Value* ADDCALL sass_list_get_value (const union Sass_Value* v, size_t i);
    attach_function :sass_list_get_length, [:sass_value_ptr], :size_t
    attach_function :sass_list_get_value, [:sass_value_ptr, :size_t], :sass_value_ptr

    # Getters for custom function descriptors
    # ADDAPI const char* ADDCALL sass_function_get_signature (Sass_C_Function_Callback fn);
    # ADDAPI Sass_C_Function ADDCALL sass_function_get_function (Sass_C_Function_Callback fn);
    # ADDAPI void* ADDCALL sass_function_get_cookie (Sass_C_Function_Callback fn);
    attach_function :sass_function_get_signature, [:sass_c_function_callback_ptr], :string
    attach_function :sass_function_get_function, [:sass_c_function_callback_ptr], :sass_c_function
    attach_function :sass_function_get_cookie, [:sass_c_function_callback_ptr], :pointer

    # Creators for custom importer callback (with some additional pointer)
    # The pointer is mostly used to store the callback into the actual binding
    # ADDAPI Sass_C_Import_Callback ADDCALL sass_make_importer (Sass_C_Import_Fn, void* cookie);
    attach_function :sass_make_importer, [:sass_c_import_function, :pointer], :sass_importer

    # Getters for import function descriptors
    # ADDAPI Sass_C_Import_Fn ADDCALL sass_import_get_function (Sass_C_Import_Callback fn);
    # ADDAPI void* ADDCALL sass_import_get_cookie (Sass_C_Import_Callback fn);

    # Deallocator for associated memory
    # ADDAPI void ADDCALL sass_delete_importer (Sass_C_Import_Callback fn);

    # Creator for sass custom importer return argument list
    # ADDAPI struct Sass_Import** ADDCALL sass_make_import_list (size_t length);
    attach_function :sass_make_import_list, [:size_t], :sass_import_list_ptr

    # Creator for a single import entry returned by the custom importer inside the list
    # ADDAPI struct Sass_Import* ADDCALL sass_make_import_entry (const char* path, char* source, char* srcmap);
    # ADDAPI struct Sass_Import* ADDCALL sass_make_import (const char* path, const char* base, char* source, char* srcmap);
    attach_function :sass_make_import_entry, [:string, :pointer, :pointer], :sass_import_ptr

    # Setters to insert an entry into the import list (you may also use [] access directly)
    # Since we are dealing with pointers they should have a guaranteed and fixed size
    # ADDAPI void ADDCALL sass_import_set_list_entry (struct Sass_Import** list, size_t idx, struct Sass_Import* entry);
    attach_function :sass_import_set_list_entry, [:sass_import_list_ptr, :size_t, :sass_import_ptr], :void
    # ADDAPI struct Sass_Import* ADDCALL sass_import_get_list_entry (struct Sass_Import** list, size_t idx);

    # Getters for import entry
    # ADDAPI const char* ADDCALL sass_import_get_path (struct Sass_Import*);
    attach_function :sass_import_get_path, [:sass_import_ptr], :string
    # ADDAPI const char* ADDCALL sass_import_get_base (struct Sass_Import*);
    # ADDAPI const char* ADDCALL sass_import_get_source (struct Sass_Import*);
    attach_function :sass_import_get_source, [:sass_import_ptr], :string
    # ADDAPI const char* ADDCALL sass_import_get_srcmap (struct Sass_Import*);
    # Explicit functions to take ownership of these items
    # The property on our struct will be reset to NULL
    # ADDAPI char* ADDCALL sass_import_take_source (struct Sass_Import*);
    # ADDAPI char* ADDCALL sass_import_take_srcmap (struct Sass_Import*);

    # Deallocator for associated memory (incl. entries)
    # ADDAPI void ADDCALL sass_delete_import_list (struct Sass_Import**);
    # Just in case we have some stray import structs
    # ADDAPI void ADDCALL sass_delete_import (struct Sass_Import*);
  end
end
