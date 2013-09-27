# encoding: UTF-8
module Maintain
  class BitmaskValue < Value
    include Enumerable

    def to_a
      @state.states.select do |key, options|
        options[:value] & @value > 0
      end.map(&:first)
    end

    def each(&block)
      to_a.each {|state| yield state }
    end

    def initialize(state, value = nil)
      @state = state
      @value = value
    end

    def set_value(value)
      @value = bitmask_for(value)
    end

    protected
    def bitmask_for(states)
      bitmask_values = Array(states).compact.map do |value|
        value_for(value)
      end.compact.sort
      bitmask_values.inject(0) {|total, mask| total | mask.to_i }
    end

    def compare_value
      @value ||= 0
    end

    def compare_value_for(state)
      bitmask_for(state)
    end

    def method_missing(method, *args)
      if (method.to_s =~ /^(.+)(\?|!)$/) && @state.states.has_key?($1.to_sym)
        compare = value_for($1)
        if $2 == '?'
          self.class.class_eval <<-EOC
            def #{method}
              value_for(@value) & #{compare.inspect} != 0
            end
          EOC
          value_for(@value) & compare != 0
        else
          self.class.class_eval <<-EOC
            def #{method}
              @value = (@value || 0) | #{compare.inspect}
            end
          EOC
          @value = (@value || 0) | compare
        end
      else
        super
      end
    end
  end
end
