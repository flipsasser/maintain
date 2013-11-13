module Maintain
  module Value
    class String < DelegateClass(String)
      include Maintain::Value

      private

      def cast(value)
        value ? value.to_s : value
      end

    end
  end
end
