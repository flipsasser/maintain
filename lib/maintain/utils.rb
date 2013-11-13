module Maintain
  module Utils
    extend self

    def call_method_or_proc(method, instance)
      if method.is_a?(Proc)
        instance.instance_eval(&method)
      else
        instance.send(method)
      end
    end

    def method_free?(klass, method_name, class_method = false)
      # Ugly hack so we don't fetch it 100 times for no reason
      if class_method
        return false if klass.respond_to?(method_name)
        methods = klass.public_methods
        methods += klass.private_methods
        methods += klass.protected_methods
      else
        methods = klass.instance_methods
      end
      !methods.map(&:to_sym).include?(method_name.to_sym)
    end

    def method_taken?(klass, method_name, class_method = false)
      !method_free?(klass, method_name, class_method)
    end

  end
end
