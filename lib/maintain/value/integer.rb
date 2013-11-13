module Maintain
  module Value
    class Integer < DelegateClass(Fixnum)
      include Maintain::Value

      private

      def cast(value)
        value ? value.to_i : value
      end

    end
  end
end
