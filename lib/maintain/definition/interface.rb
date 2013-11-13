# Maintain::Definition::Interface delegates configuration from a
# block interface (Class.maintains :state { ...configure... } to
# the definition itself.

module Maintain
  class Definition
    class Interface

      def initialize(definition)
        @definition = definition
      end

      def aggregate(name, states, options = {})
        name = name.to_sym
        if states.is_a?(Hash)
          options = states
          states = options.delete(:as)
        end
        aggregate = Maintain::Aggregate.new(name, states, options)
        @definition.aggregates[name] = aggregate
      end

      def state(name, value = nil, options = {})
        name = name.to_sym
        if value.is_a?(Hash)
          options = value
          value = nil
        end
        if @definition.bitmask?
          add_bitmask_state(name, value, options)
        elsif @definition.integer?
          add_integer_state(name, value, options)
        elsif value.is_a?(Integer)
          @definition.integer = true
          state(name, value, options)
        else
          add_state(name, value || name.to_s, options)
        end
      end

      protected

      def add_bitmask_state(name, value, options)
        value = @counter unless value.is_a?(Integer)
        value = 2 ** value.to_i
        add_state(name, value, options)
      end

      def add_integer_state(name, value, options)
        add_state(name, value || @counter, options)
      end

      def add_state(name, value, options)
        state = Maintain::State.new(name, value, options)
        if !@definition.bitmask? && value.is_a?(Integer)
          state.comparator = value
        else
          state.comparator = @counter
        end
        @definition.states[name] = state
        @definition.counter += 1
        #if back_end
        #back_end.state maintainee, name, @attribute, value.is_a?(Symbol) ? value.to_s : value, force: options[:force]
        #end
      end

    end
  end
end

