module Maintain
  module Value
    class Integer < DelegateClass(Fixnum)
      include Maintain::Value

      private

      def cast(value)
        value.to_s.to_i
      end

    end
  end
end
