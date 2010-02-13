module Maintain
  module Methods
    # The core class method of Maintain. Basic usage is:
    # 
    #   maintain :state do
    #     state :new, :default => true
    #     state :expired, :enter => :expire_children
    #     state :reopened, :exit => lambda { children.each(&:reopen) }
    #     aggregate :accessible, :as => [:new, :reopened]
    #   end
    # 
    # It also supports more complex configuration options, like bitmask columns
    # and integer values (for performance and portability)
    # 
    #   maintain :permissions, :bitmask => true do
    #     state :edit, 1
    #     state :delete, 2
    #     state :manage, 3
    #   end
    def maintain(attribute, options = {}, &block)
      maintainer = State.new(attribute, options)
      if block_given?
        maintainer.instance_eval(&block)
      end
      if defined?(ActiveRecord::Base)
        active_record = false
        superclass = self.superclass
        while !active_record && superclass.superclass
          if superclass == ActiveRecord::Base
            active_record = true
          end
          superclass = superclass.superclass
        end
      else
        active_record = false
      end
      # raise active_record.inspect
      class_eval <<-EOC
        def #{attribute}=(value)
          @#{attribute} ||= self.class.maintainers[#{attribute.to_sym.inspect}].value
          unless @#{attribute}.set_value(value)
            @#{attribute} = nil
          end#{%{
          if private_methods.include?('write_attribute')
            write_attribute(:#{attribute}, @#{attribute} ? @#{attribute}.value.to_s : nil)
          end
          } if active_record}
        end

        def #{attribute}
          return @#{attribute} if @#{attribute}
          if self.class.maintainers[#{attribute.to_sym.inspect}].default? || self.class.maintainers[#{attribute.to_sym.inspect}].bitmask?
            @#{attribute} = self.class.maintainers[#{attribute.to_sym.inspect}].value#{"(read_attribute(:#{attribute}))" if active_record}
          end
        end
      EOC

      methods = public_instance_methods + private_instance_methods + protected_instance_methods
      maintainer.states.keys.each do |method_name|
        method_name = "#{method_name}?"
        unless methods.include?(method_name)
          class_eval <<-EOC
            def #{method_name}
              #{attribute}.#{method_name}
            end
          EOC
        end
      end

      maintainers[attribute.to_sym] = maintainer
    end
    alias :maintains :maintain

    def maintainers #:nodoc:
      @maintainers ||= {}
    end
  end
end