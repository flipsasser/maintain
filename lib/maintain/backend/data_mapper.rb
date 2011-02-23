module Maintain
  module Backend
    class DataMapper < Maintain::Backend::Base
      def aggregate(maintainee, name, attribute, states)
        # named_scope will handle the array of states as "IN" in SQL
        state(maintainee, name, attribute, states)
      end

      def read(instance, attribute)
        instance.attributes[attribute.to_s]
      end

      def state(maintainee, name, attribute, value)
        conditions = {:conditions => {attribute => value}}
        maintainee.class_eval <<-scope
          def self.#{name}
            all(#{conditions.inspect})
          end
        scope
      end

      def write(instance, attribute, value)
        property = instance.send(:properties)[attribute]
        instance.persisted_state = instance.persisted_state.set(property, value)
        instance.persisted_state.get(property)
      end
    end
  end
end
