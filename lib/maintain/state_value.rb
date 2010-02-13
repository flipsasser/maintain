module Maintain
  class StateValue
    def >(value)
      compare_value > compare_value_for(value)
    end

    def >=(value)
      compare_value >= compare_value_for(value)
    end

    def <(value)
      compare_value < compare_value_for(value)
    end

    def <=(value)
      compare_value <= compare_value_for(value)
    end

    def ==(value)
      compare_value == compare_value_for(value)
    end

    def class
      value.class
    end

    def initialize(state, value = nil)
      @state = state
      @value = value
    end

    def inspect
      value.inspect
    end

    def nil?
      value.nil?
    end

    def set_value(value)
      @compare_value = nil
      @value = state_name_for(value)
    end

    def to_s
      value.to_s
    end

    def value
      @value
    end

    private
    def compare_value
      @compare_value ||= compare_value_for(@value)
    end

    def compare_value_for(state)
      state_value_for(state, :compare_value)
    end

    def method_missing(method, *args)
      if (method.to_s =~ /^(.+)\?$/) && @state.states.has_key?($1.to_sym)
        self.class.class_eval <<-EOC
          def #{method}
            self == #{$1.to_sym.inspect}
          end
        EOC
        # Calling `method` on ourselves fails. Something to do w/subclasses. Meh.
        self == $1.to_sym
      else
        super
      end
    end

    def state_name_for(value)
      if (value.is_a?(String) || value.is_a?(Symbol))
        @state.states.has_key?(value.to_sym) ? value.to_sym : nil
      else
        @state.state_name_for(value)
      end
    end

    def state_value_for(state, value)
      if (state.is_a?(String) || state.is_a?(Symbol)) && state_hash = @state.states[state.to_sym]
        state_hash[value]
      else
        state
      end
    end

    def value_for(state)
      state_value_for(state, :value)
    end
  end
end