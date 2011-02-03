module Maintain
  module Backend
    class Base
      def aggregate(maintainee, attribute, name, options, states)
        require_method :aggregate
      end

      def read(instance, attribute)
        require_method :read
      end

      def write(instance, attribute, value)
        require_method :write
      end

      private
      def require_method(method_name)
        raise "You need to implement the ##{method_name} method in #{self.class.name}"
      end
    end
  end
end
