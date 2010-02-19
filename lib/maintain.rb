module Maintain
  # We're not really interested in loading anything into memory if we don't need to,
  # so Maintainer, Value, and the Value subclasses are ignored until they're needed.
  autoload(:Maintainer, 'lib/maintain/maintainer')
  autoload(:Value, 'lib/maintain/value')
  autoload(:BitmaskValue, 'lib/maintain/bitmask_value')
  autoload(:IntegerValue, 'lib/maintain/integer_value')

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
  # 
  # This method is aliased as `maintains` with the intention of allowing developers
  # to code imperatively ("maintain, damn you!") or descriptively ("it maintains, man")
  def maintain(attribute, options = {}, &block)
    # Detect if this is ActiveRecord::Base or a subclass of it
    # TODO: Make this not suck
    if defined?(ActiveRecord::Base)
      active_record = self == ActiveRecord::Base
      superclass = self
      while !active_record && superclass.superclass
        active_record = superclass == ActiveRecord::Base
        superclass = superclass.superclass
      end
    else
      active_record = false
    end

    # Create an instance of the maintainer class. It handles all of the state
    # configuration, hooking, aggregation, named_scoping, etc.
    maintainer = Maintainer.new(self, attribute, active_record, options)
    if block_given?
      maintainer.instance_eval(&block)
    end

    # Define our getters and setters - these are the only methods Maintain will stomp
    # on if you've already defined them. This is because they're how Maintain works.
    class_eval <<-EOC
      def #{attribute}=(value)
        # If we can find the maintainer on this attribute, we'll use it to set values.
        if maintainer = self.class.maintainers[#{attribute.to_sym.inspect}]
          # First, we instantiate a value on this maintainer if we haven't already
          @#{attribute} ||= maintainer.value

          # Then run the exit hook if we're changing the value
          maintainer.hook(:exit, @#{attribute}.value, self)

          # Then set the value itself. Maintainer::State will return the value you set,
          # so if we're setting to nil we get rid of the attribute entirely - it's not
          # needed and we want the getter to return nil in that case.
          unless @#{attribute}.set_value(value)
            @#{attribute} = nil
          end#{%{

          # If this is ActiveRecord::Base or a subclass of it, we'll make sure calling the
          # setter writes a DB-friendly value.
          if respond_to?(:write_attribute)
            write_attribute(:#{attribute}, @#{attribute} ? @#{attribute}.value.to_s : nil)
          end
          } if active_record}

          # Last but not least, run the enter hooks for the new value - cause that's how we
          # do.
          maintainer.hook(:enter, @#{attribute}.value, self) if @#{attribute}
        else
          # If we can't find a maintainer for this attribute, make our best effort to do what
          # attr_accessor does - set the instance variable.
          @#{attribute} = value#{%{

          # ... and on ActiveRecord::Base, we'll also write the attribute like a normal setter.
          if respond_to?(:write_attribute)
            write_attribute(:#{attribute}, @#{attribute})
          end
          } if active_record}
        end
      end

      def #{attribute}
        # Start by returning an already-instantiated Maintainer::State if it exists
        return @#{attribute} if @#{attribute}

        # If'n it doesn't already exist AND this maintained attribute has a default value (and
        # bitmasks must have at least a 0 value), we'll instantiate a Maintainer::State and return
        # it.
        if self.class.maintainers[#{attribute.to_sym.inspect}].default? || self.class.maintainers[#{attribute.to_sym.inspect}].bitmask?
          @#{attribute} = self.class.maintainers[#{attribute.to_sym.inspect}].value#{"(read_attribute(:#{attribute}))" if active_record}
        end
      end
    EOC

    # Last! Not least! Save our maintainer directly on this class. We'll use it in our setters (as in above)
    # and we'll also modify it instead of replacing it outright, so subclasses or mixins can extend functionality
    # without replacing it.
    maintainers[attribute.to_sym] = maintainer
  end
  alias :maintains :maintain

  def maintainers #:nodoc:
    @maintainers ||= {}
  end
end

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend Maintain
end