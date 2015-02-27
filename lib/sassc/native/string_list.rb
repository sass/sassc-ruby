module SassC
  module Native
    class StringList < FFI:Struct
      layout :string_list, StringList.val,
             :string, :string
    end
  end
end

