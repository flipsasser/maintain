module Maintain
  class Maintainer
    def aggregate(name, options)
      if options.is_a?(Hash) && options.has_key?(:as)
        options = options[:as]
      end
      aggregates[name] = options
      # Now we're going to add proxies to test for state being in this aggregate. Don't create
      # this method unless it doesn't exist.
      boolean_method = "#{name}?"
      if method_free?(boolean_method)
        # Define it if'n it don't already exit! These are just proxies - so Foo.maintains(:state) { state :awesome }
        # will now have Foo.new.awesome?. But that's really just a proxy for Foo.new.state.awesome?
        # So they're just shortcuts for brevity's sake.
        maintainee.class_eval <<-EOC
          def #{boolean_method}
            #{@attribute}.#{boolean_method}
          end
        EOC
      end
      # Now define the state
      if @active_record && method_free?(name, true)
        maintainee.named_scope name, :conditions => {@attribute => options}
      end
    end

    def aggregates
      @aggregates ||= {}
    end

    def bitmask(value)
      @bitmask = !!value
    end

    def bitmask?
      @bitmask
    end

    def default(state)
      @default = state
    end

    def default?
      !!@default
    end

    def hook(event, state, instance)
      if state && hooks[state.to_sym] && hooks[state.to_sym][event.to_sym]
        hooks[state.to_sym][event.to_sym].each do |method|
          if method.is_a?(Proc)
            instance.instance_eval(&method)
          else
            instance.send(method)
          end
        end
      end
    end

    def initialize(maintainee, attribute, active_record = false, options = {})
      @maintainee = maintainee.name
      @attribute = attribute.to_sym
      @active_record = !!active_record
      options.each do |key, value|
        self.send(key, value)
      end
    end

    def integer(value)
      @integer = !!value
    end

    def on(event, state, method = nil, &block)
      if block_given?
        method = block
      end
      hooks[state.to_sym] ||= {}
      hooks[state.to_sym][event.to_sym] ||= []
      hooks[state.to_sym][event.to_sym].push(method) unless hooks[state.to_sym][event.to_sym].include?(method)
    end

    def state_name_for(value)
      if value = states.find {|key, options| options[:compare_value] == value}
        value[0]
      end
    end

    def state(name, value = nil, options = {})
      if value.is_a?(Hash)
        options = value
        value = nil
      end
      if options.has_key?(:default)
        default(name)
      end
      @increment ||= 0
      if @bitmask
        unless value.is_a?(Integer)
          value = @increment
        end
        value = 2 ** value.to_i
      elsif value.is_a?(Integer)
        integer(true)
      end
      value ||= name
      states[name] = {:compare_value => !@bitmask && value.is_a?(Integer) ? value : @increment, :value => value}
      @increment += 1
      if @active_record && !maintainee.respond_to?(name)
        conditions = {}
        maintainee.named_scope name, :conditions => {@attribute => value.is_a?(Symbol) ? value.to_s : value}
      end

      # Now we're going to add proxies to test for state. These methods only get added if a
      # method of their name doesn't already exist.
      boolean_method = "#{name}?"
      if method_free?(boolean_method)
        # Define it if'n it don't already exit! These are just proxies - so Foo.maintains(:state) { state :awesome }
        # will now have Foo.new.awesome?. But that's really just a proxy for Foo.new.state.awesome?
        # So they're just shortcuts for brevity's sake.
        maintainee.class_eval <<-EOC
          def #{boolean_method}
            #{@attribute}.#{boolean_method}
          end
        EOC
      end
    end

    def states
      @states ||= {}
    end

    def value(initial = nil)
      if @bitmask
        BitmaskValue.new(self, initial || @default || 0)
      elsif @integer
        IntegerValue.new(self, initial || @default)
      else
        Value.new(self, initial || @default)
      end
    end

    protected
    def hooks
      @hooks ||= {}
    end

    def maintainee
      Object.const_get(@maintainee)
    end

    def method_free?(method_name, class_method = false)
      # Ugly hack so we don't fetch it 100 times for no reason
      maintainee_class = maintainee
      if class_method
        respond_to = maintainee_class.respond_to?(method_name)
        methods = maintainee_class.public_methods + maintainee_class.private_methods + maintainee_class.protected_methods
      else
        respond_to = false
        methods = maintainee_class.public_instance_methods + maintainee_class.private_instance_methods + maintainee_class.protected_instance_methods
      end
      !respond_to && !methods.include?(method_name)
    end

    def method_missing(method, *args)
      if states.has_key?(method)
        states[method][:value]
      else
        super
      end
    end
  end
end