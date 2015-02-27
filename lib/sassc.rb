module SassC
end

require_relative "sassc/version"
require_relative "sassc/native"
require_relative "sassc/engine"

puts SassC::Native.version


data_context = SassC::Native.sass_make_data_context("$size: 30px; .hi { width: $size; }")
context = SassC::Native.sass_data_context_get_context(data_context)
options = SassC::Native.sass_context_get_options(context)

status = SassC::Native.sass_compile_data_context(data_context)

if status == 0
  puts SassC::Native.sass_context_get_output_string(context)
else
  puts "error"
  puts SassC::Native.sass_context_get_error_message(context)
end

SassC::Native.sass_delete_data_context(data_context)
