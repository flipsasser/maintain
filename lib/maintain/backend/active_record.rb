module Maintain
  module Backend
    class ActiveRecord < Maintain::Backend::Base
      def aggregate(maintainee, name, attribute, states, options = {})
        # named_scope will handle the array of states as "IN" in SQL
        state(maintainee, name, attribute, states, options.merge(dirty: false))
      end

      def on(maintainee, attribute, event, state, method, options)
        attribute_check = "#{attribute}#{"_was" if event == :exit}_#{state}?"
        hook_method = options[:after] ? :after : :before
        maintainee.send("#{hook_method}_save", method, if: lambda {|instance|
          if instance.send("#{attribute}_changed?") && instance.send(attribute_check)
            if options[:if]
              Maintainer.call_method_or_proc(options[:if], instance)
            elsif options[:unless]
              !Maintainer.call_method_or_proc(options[:unless], instance)
            else
              true
            end
          else
            false
          end
        })
      end

      def read(instance, attribute)
        instance.read_attribute(attribute)
      end

      def state(maintainee, name, attribute, value, options = {})
        options = {dirty: true}.merge(options)
        conditions = {conditions: {attribute => value}}
        version = defined?(::ActiveRecord::VERSION) && ::ActiveRecord::VERSION::STRING
        force = !maintainee.respond_to?(name) || options[:force]
        if version && version >= '3'
          where = "lambda { where(#{conditions[:conditions].inspect}) }"
          maintainee.class_eval "scope :#{name}, #{where}" if force
          maintainee.class_eval "scope :#{attribute}_#{name}, #{where}"
        else
          maintainee.named_scope(name, conditions)
          maintainee.named_scope("#{attribute}_#{name}", conditions)
        end

        if options[:dirty]
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
