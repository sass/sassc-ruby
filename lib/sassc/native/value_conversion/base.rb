module SassC
  module Native
    module ValueConversion
      class Base
        def self.to_native(value)
          case value.class.name.split("::").last
          when "String"
            String.new(value).to_native
          when "Color"
            Color.new(value).to_native
          else
            raise "not implemented"
          end
        end

        def initialize(value)
          @value = value
        end
      end
    end
  end
end
