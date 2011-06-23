module Maintain
  module Backend
    class ActiveRecord < Maintain::Backend::Base
      def aggregate(maintainee, name, attribute, states)
        # named_scope will handle the array of states as "IN" in SQL
        state(maintainee, name, attribute, states, false)
      end

      def on(maintainee, attribute, event, state, method, options)
        attribute_check = "#{attribute}#{"_was" if event == :exit}_#{state}?"
        maintainee.before_save method, :if => lambda {|instance|
          instance.send("#{attribute}_changed?") && instance.send(attribute_check) &&
            (!options[:if] || (options[:if].is_a?(Proc) && instance.instance_eval(&options[:unless])) || instance.send(options[:if])) &&
            (!options[:unless] || !(options[:unless].is_a?(Proc) && instance.instance_eval(&options[:unless])) || !instance.send(options[:unless]))
        }
      end

      def read(instance, attribute)
        instance.read_attribute(attribute)
      end

      def state(maintainee, name, attribute, value, dirty = true)
        conditions = {:conditions => {attribute => value}}
        if defined?(::ActiveRecord::VERSION) && ::ActiveRecord::VERSION::STRING >= '3'
          maintainee.scope name, conditions
        else
          maintainee.named_scope name, conditions
        end
        if dirty
          maintainee.class_eval <<-dirty_tracker
            def #{attribute}_was_#{name}?
              #{attribute}_was == self.class.maintainers[:#{attribute}].value(self).value_for(:#{name})
            end
          dirty_tracker
        end
      end

      def write(instance, attribute, value)
        instance.send(:write_attribute, attribute, value)
      end
    end
  end
end
