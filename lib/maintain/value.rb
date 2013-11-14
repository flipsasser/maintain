# encoding: UTF-8
module Maintain
  module Value

    autoload(:Bitmask, 'maintain/value/bitmask')
    autoload(:Integer, 'maintain/value/integer')
    autoload(:String, 'maintain/value/string')

    attr_reader :definition, :state

    def initialize(value, definition, instance)
      value = cast(value)
      super(value)
      @definition = definition
      @state = @definition.states.values.find do |state|
        state.value == value
      end
      @instance = instance
      @value = value
    end

    def >(comparison_value)
      @value > detect_value(comparison_value)
    end

    def >=(comparison_value)
      @value >= detect_value(comparison_value)
    end

    def <(comparison_value)
      @value < detect_value(comparison_value)
    end

    def <=(comparison_value)
      @value <= detect_value(comparison_value)
    end

    def ==(comparison_value)
      super detect_value(comparison_value)
    end

    def ===(comparison_value)
      raise @value.inspect
      (compare_value == compare_value_for(value)) || super
    end

    def name
      state && state.name.to_s
    end

    private

    def detect_value(value)
      @definition.detect_value(value)
    end

    def __setobj__(value)
      super value
      if @instance
        @instance.send("#{definition.attribute}=", value)
      end
    end

  end
end
