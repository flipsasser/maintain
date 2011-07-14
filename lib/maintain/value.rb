# encoding: UTF-8
module Maintain
  class Value
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

    def ===(value)
      (compare_value == compare_value_for(value)) || super
    end

    def as_json(options = nil)
      @value
    end

    def class
      value.class
    end

    def initialize(state, value = nil)
      @state = state
      @value = state_name_for(value)
    end

    def inspect
      value.inspect
    end

    def name
      @value.to_s
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

    def value_for(state)
      state_value_for(state, :value)
    end

    private
    def compare_value
      @compare_value ||= compare_value_for(@value)
    end

    def compare_value_for(state)
      state_value_for(state, :compare_value)
    end

    # TODO: Sweet god, this is hideous and needs to be cleaned up!
    def method_missing(method, *args)
      if (method.to_s =~ /^(.+)\?$/)
        check = $1.to_sym
        if @state.states.has_key?(check)
          self.class.class_eval <<-EOC
            def #{method}
              self == #{check.inspect}
            end
          EOC
          # Calling `method` on ourselves fails. Something to do w/subclasses. Meh.
          return self == check.to_sym
        elsif aggregates = @state.aggregates[check]
          self.class.class_eval <<-EOC
            def #{method}
              @state.aggregates[#{check.inspect}].include?(@value)
            end
          EOC
          return aggregates.include?(@value)
        else
          super
        end
      elsif value_for(@value).respond_to?(method)
        value_for(@value).send(method, *args)
      else
        super
      end
    end

    def state_name_for(value)
      if value.to_s =~ /^\d+$/
        @state.state_name_for(value.to_i)
      elsif (value.is_a?(String) || value.is_a?(Symbol))
        @state.states.has_key?(value.to_sym) ? value.to_sym : nil
      end
    end

    def state_value_for(state, value)
      if (state.is_a?(String) || state.is_a?(Symbol))
        if !state.to_s.strip.empty? && state_hash = @state.states[state.to_sym]
          state_hash[value]
        else
          nil
        end
      else
        state
      end
    end
  end
end