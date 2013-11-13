require 'maintain/definition/interface'

module Maintain
  class Definition

    attr_accessor :counter
    attr_reader :attribute, :klass
    attr_writer :back_end, :bitmask, :integer, :string

    def initialize(klass, attribute, options = {})
      @klass = klass
      @attribute = attribute
      @counter = 0
      options.each do |key, value|
        self.send("#{key}=", value)
      end
    end

    def aggregates
      @aggregates ||= {}
    end

    def bitmask?
      !!@bitmask
    end

    def default
      if bitmask?
        @default ||= states.values.inject(0) do |default_bitmask, state|
          state.options[:default] ? default_bitmask | state.value : default_bitmask
        end
      end
      @default
    end

    def default=(name_or_value)
      value = detect_value(name_or_value)
      if bitmask?
        @default = (@default || 0) | value
      else
        @default = value
      end
    end

    def define_methods!
      define_class_methods!
      define_getter!
      define_setter!
      define_state_methods!
      define_aggregate_methods!
    end

    def detect_value(name_or_value)
      if state = find_state(name_or_value)
        state.value
      else
        name_or_value
      end
    end

    def integer?
      !!@integer
    end

    def interface
      Interface.new(self)
    end

    def states
      @states ||= {}
    end

    def string?
      !integer? && !bitmask?
    end

    def value_for(value)
      value ||= default
      if bitmask?
        value = Array(value).inject(0) { |bitmask, name_or_value| bitmask | detect_value(name_or_value) }
        Maintain::Value::Bitmask.new(value, self)
      elsif integer?
        Maintain::Value::Integer.new(value, self)
      else
        Maintain::Value::String.new(value, self)
      end
    end

    protected

    def find_state(name_or_value)
      name_or_value = name_or_value.to_s
      states.values.find {|state| state.name.to_s == name_or_value }
    end

    private

    # Define accessors for each of the states that have been configured through
    # the interface
    def define_aggregate_methods!
      aggregates.values.each do |aggregate|
        aggregate.define_boolean_methods!(self)
        aggregate.define_bang_methods!(self)
      end
    end

    def define_class_methods!
      klass.class_eval <<-CLASS_METHODS, __FILE__, __LINE__.succ
        def self.maintain_#{attribute}
          @#{attribute} ||= maintainers[:#{attribute}].states.values.sort do |a, b|
            a.comparator <=> b.comparator
          end.map do |state|
            [state.name, state.value]
          end
        end
      CLASS_METHODS
      if Maintain::Utils.method_free?(klass, attribute, true)
        klass.class_eval <<-CLASS_METHOD_ALIAS, __FILE__, __LINE__.succ
          class << self
            alias :#{attribute} :maintain_#{attribute}
          end
        CLASS_METHOD_ALIAS
      end
    end

    # Define the getter. Returns a Maintain::Value delegate for the actual
    # value of the maintained attribute.
    def define_getter!
      if Maintain::Utils.method_taken?(klass, attribute)
        getter = "_maintain_#{attribute}"
        if Maintain::Utils.method_free?(klass, getter)
          klass.class_eval <<-ALIAS
            alias :#{getter} :#{attribute}
          ALIAS
        end
      else
        getter = "@#{attribute}"
      end

      klass.class_eval <<-GETTER, __FILE__, __LINE__.succ
        def #{attribute}
          definition = self.class.maintainers[:#{attribute}]
          definition.value_for(#{getter})
        end
      GETTER
    end

    # Define accessors for each of the states that have been configured through
    # the interface
    def define_state_methods!
      states.values.each do |state|
        # Shortcuts to these methods only get added if a method of their name
        # doesn't already exist.
        state.define_boolean_methods!(self)
        state.define_bang_methods!(self)
      end
    end

    # Define the setter. Either performs the default setter behavior, or stores
    # the value in an instance variable.
    def define_setter!
      setter_name = "#{attribute}=".to_sym

      if Maintain::Utils.method_taken?(klass, setter_name)
        setter = "self._maintain_#{setter_name}(value)"
        klass.class_eval <<-ALIAS
          alias :_maintain_#{setter_name} :#{setter_name}
        ALIAS
      else
        setter = "@#{attribute} = value"
      end

      klass.class_eval <<-SETTER, __FILE__, __LINE__.succ
      def #{setter_name}(value)
        definition = self.class.maintainers[:#{attribute}]
        changed = #{attribute} != value

        #definition.hook(:exit, #{attribute}.name, self) if changed
        #{setter}
        #definition.hook(:enter, #{attribute}.name, self) if changed
      end
      SETTER
    end

  end
end
