require 'maintain/utils'

module Maintain
  class State

    include Maintain::Utils

    attr_reader :name, :options, :value
    attr_accessor :comparator

    def initialize(name, value, options = {})
      @name = name
      @value = value
      @options = options
    end

    def define_boolean_methods!(definition)
      define_with_alias(definition, "#{name}?", %{
        #{definition.attribute} == #{value.inspect}
      })
    end

    def define_bang_methods!(definition)
      define_with_alias(definition, "#{name}!", %{
        self.#{definition.attribute} = #{value.inspect}
      })
    end

    private

    def define_with_alias(definition, method, code)
      full_method = "#{definition.attribute}_#{method}"

      definition.klass.class_eval <<-FULL_METHOD
      def #{full_method}
        #{code}
      end
      FULL_METHOD

      if options[:force] || method_free?(definition.klass, method)
        definition.klass.class_eval <<-ALIAS_METHOD
          alias :#{method} :#{full_method}
        ALIAS_METHOD
      end
    end

  end
end
