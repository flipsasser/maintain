module Maintain
  module Value
    class String < DelegateClass(String)
      include Maintain::Value

      private

      def cast(value)
        value.to_s
      end

    end
  end
end
