# encoding: UTF-8
$LOAD_PATH.unshift File.join(File.dirname(__FILE__))
require 'maintain/backend'

module Maintain
  # We're not really interested in loading anything into memory if we don't need to,
  # so Maintainer, Value, and the Value subclasses are ignored until they're needed.
  autoload(:Maintainer, 'maintain/maintainer')
  autoload(:Value, 'maintain/value')
  autoload(:BitmaskValue, 'maintain/bitmask_value')
  autoload(:IntegerValue, 'maintain/integer_value')

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
    options[:back_end] ||= Maintain::Backend.detect(self)

    # Create an instance of the maintainer class. It handles all of the state
    # configuration, hooking, aggregation, named_scoping, etc.
    maintainer = Maintainer.new(self, attribute, options)
    if block_given?
      maintainer.instance_eval(&block)
    end

    # Define our getters and setters - these are the only methods Maintain will stomp
    # on if you've already defined them. This is because they're how Maintain works.
    class_eval <<-EOC, __FILE__
      def #{attribute}=(value)
        # Find the maintainer on this attribute so we can use it to set values.
        maintainer = self.class.maintainers[:#{attribute}]
        changed = #{attribute} != value
        # Run the exit hook if we're changing the value
        maintainer.hook(:exit, #{attribute}.name, self) if changed

        # Then set the value itself. Maintainer::State will return the value you set,
        # so if we're setting to nil we get rid of the attribute entirely - it's not
        # needed and we want the getter to return nil in that case.
        #{attribute}.set_value(value)

        # Allow the back end to write values in an ORM-specific way
        if maintainer.back_end
          maintainer.back_end.write(self, :#{attribute}, #{attribute}.value)
        end

        # Last but not least, run the enter hooks for the new value - cause that's how
        # we do.
        maintainer.hook(:enter, #{attribute}.name, self) if changed
      end

      def #{attribute}
        @#{attribute} ||= self.class.maintainers[:#{attribute}].value(self)
      end
    EOC

    class_eval <<-EOC, __FILE__
      class << self
        def maintain_#{attribute}
          @#{attribute} ||= maintainers[:#{attribute}].states.sort{|a, b| (a[1][:compare_value] || a[1][:value]) <=> (b[1][:compare_value] || b[1][:value]) }.map{|key, value| key == value[:value] ? key : [key, value[:value]]}
        end
        #{"alias :#{attribute} :maintain_#{attribute}" unless respond_to?(attribute)}
      end
    EOC

    # Last! Not least! Save our maintainer directly on this class. We'll use it in our setters (as in above)
    # and we'll also modify it instead of replacing it outright, so subclasses or mixins can extend functionality
    # without replacing it.
    maintainers[attribute.to_sym] = maintainer
  end
  alias :maintains :maintain

  def maintainers #:nodoc:
    @maintainers ||= begin
      maintainers = {}
      superk = superclass
      while superk.respond_to?(:maintainers)
        maintainers.merge!(superk.maintainers)
        superk = superk.superclass
      end
      maintainers
    end
  end

  if File.file?(version_path = File.join(File.dirname(__FILE__), '..', 'VERSION'))
    VERSION = File.read(version_path).strip
  else
    VERSION = '0.2.0'
  end
end

Maintain::Backend.add(:active_record, 'ActiveRecord::Base')
Maintain::Backend.add(:data_mapper, 'DataMapper::Resource')
