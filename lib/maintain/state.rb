module Maintain
  class State
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

    def initialize(state, options = {})
      options = {:bitmask => false, :default => nil, :integer => false}.merge(options)
      options.each do |key, value|
        self.send(key, value)
      end
    end

    def integer(value)
      @integer = !!value
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
      if options[:default]
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
    end

    def states
      @states ||= {}
    end

    def value(initial = nil)
      if @bitmask
        BitmaskStateValue.new(self, initial || @default || 0)
      elsif @integer
        IntegerStateValue.new(self, initial || @default)
      else
        StateValue.new(self, initial || @default)
      end
    end

    protected
    def method_missing(method, *args)
      if states.has_key?(method)
        states[method][:value]
      else
        super
      end
    end
  end
end