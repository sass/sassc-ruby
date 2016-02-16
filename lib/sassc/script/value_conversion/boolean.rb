module SassC
  module Script
    module ValueConversion
      class Boolean < Base
        def to_native
          Native::make_boolean(@value.value)
        end
      end
    end
  end
end
