module Maintain
  module Backend
    class ActiveRecord < Maintain::Backend::Base
      def aggregate(maintainee, name, attribute, states)
        # named_scope will handle the array of states as "IN" in SQL
        state(maintainee, name, attribute, states)
      end

      def read(instance, attribute)
        instance.attributes[attribute.to_s]
      end

      def state(maintainee, name, attribute, value)
        conditions = {:conditions => {attribute => value}}
        if defined?(::ActiveRecord::VERSION) && ::ActiveRecord::VERSION::STRING >= '3'
          maintainee.scope name, conditions
        else
          maintainee.named_scope name, conditions
        end
      end

      def write(instance, attribute, value)
        instance.send(:write_attribute, attribute, value)
      end
    end
  end
end
