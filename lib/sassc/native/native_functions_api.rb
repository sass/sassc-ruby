module SassC
  module Native
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
