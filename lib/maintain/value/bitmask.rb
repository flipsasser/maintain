require 'maintain/value'

module Maintain
  module Value
    class Bitmask < DelegateClass(Fixnum)
      include Enumerable
      include Maintain::Value

      def ==(comparison_value)
        super(detect_value(comparison_value)) || to_a == comparison_value
      end

      def ===(comparison_value)
        super(detect_value(comparison_value)) || to_a === comparison_value
      end

      def to_a
        definition.states.select do |name, state|
          self & state.value > 0
        end.map(&:first)
      end

      alias :to_array :to_a

      def each(&block)
        to_a.each {|state| yield state }
      end

      private

      def cast(values)
        Array(values).inject(0) { |bitmask, value| bitmask | value.to_i }
      end

      def method_missing(method, *args)
        if (method.to_s =~ /^(.+)(\?|!)$/) && state = definition.states[$1.to_sym]
          if $2 == '?'
            self.class.class_eval <<-EOC
            def #{method}
              self & #{state.value} != 0
            end
            EOC
            self & state.value != 0
          else
            self.class.class_eval <<-EOC
            def #{method}
              __setobj__(self | #{state.value})
            end
            EOC
            __setobj__(self | state.value)
          end
        else
          super
        end
      end
    end

  end
end
