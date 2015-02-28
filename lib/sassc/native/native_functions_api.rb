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


    # Getters for custom function descriptors
    # ADDAPI const char* ADDCALL sass_function_get_signature (Sass_C_Function_Callback fn);
    # ADDAPI Sass_C_Function ADDCALL sass_function_get_function (Sass_C_Function_Callback fn);
    # ADDAPI void* ADDCALL sass_function_get_cookie (Sass_C_Function_Callback fn);
    attach_function :sass_function_get_signature, [:sass_c_function_callback_ptr], :string
    attach_function :sass_function_get_function, [:sass_c_function_callback_ptr], :sass_c_function
    attach_function :sass_function_get_cookie, [:sass_c_function_callback_ptr], :pointer


    #callback :sass_c_function, [SassValue.ptr, :pointer], SassValue.ptr
    Callback = FFI::Function.new(:pointer, [:pointer, :pointer]) do |s_args, cookie|
      SassC::Native.make_number(43, "px")
    end
  end
end
