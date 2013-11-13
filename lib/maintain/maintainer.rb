# encoding: UTF-8
module Maintain
  class Maintainer
    attr_reader :back_end

    def hook(event, state, instance)
      if state && state.to_s.strip != '' && hooks[state.to_sym]
        hook_definitions = hooks[state.to_sym][event.to_sym] || []
        hook_definitions.each do |hook_definition|
          if hook_definition[:if]
            next unless call_method_or_proc(hook_definition[:if], instance)
          end
          if hook_definition[:unless]
            next if call_method_or_proc(hook_definition[:unless], instance)
          end
          call_method_or_proc(hook_definition[:method], instance)
        end
      end
    end

    def initialize(maintainee, attribute, options = {})
      if back_end = options.delete(:back_end)
        @back_end = Maintain::Backend.build(back_end)
      end
      options.each do |key, value|
        self.send(key, value)
      end
    end

    def on(*args, &block)
      options = {when: :before}.merge(args.last.is_a?(Hash) ? args.pop : {})
      event, state = args.shift, args.shift
      method = args.shift
      if block_given?
        method = block
      end
      if back_end && back_end.respond_to?(:on)
        back_end.on(maintainee, @attribute, event, state, method, options)
      else
        hooks[state.to_sym] ||= {}
        hooks[state.to_sym][event.to_sym] ||= []
        method_hash = {method: method}.merge(options)
        if old_definition = hooks[state.to_sym][event.to_sym].find{|hook| hook[:method] == method}
          old_definition.merge!(method_hash)
        else
          hooks[state.to_sym][event.to_sym].push(method_hash)
        end
      end
    end

    def state(name, value = nil, options = {})
      if value.is_a?(Hash)
        options = value
        value = nil
      end
      @increment ||= 0
      if bitmask?
        unless value.is_a?(Integer)
          value = @increment
        end
        value = 2 ** value.to_i
      elsif value.is_a?(Integer)
        integer(true)
      end
      value ||= name
      states[name] = {compare_value: !bitmask? && value.is_a?(Integer) ? value : @increment, value: value}
      @increment += 1
      if back_end
        back_end.state maintainee, name, @attribute, value.is_a?(Symbol) ? value.to_s : value, force: options[:force]
      end

      # We need the states hash to contain the compare_value for this guy
      # before we can set defaults on the bitmask, since the default should
      # actually be a bitmask of all possible default states
      if options.has_key?(:default)
        default(name)
      end

      if options.has_key?(:enter)
        on :enter, name.to_sym, options.delete(:enter)
      end

      if options.has_key?(:exit)
        on :exit, name.to_sym, options.delete(:exit)
      end

      # Now we're going tests for state. Shortcuts to these methods only get
      # added if a method of their name doesn't already exist.
      boolean_method = "#{name}?"
      shortcut = options[:force] || method_free?(boolean_method)
      maintainee.class_eval <<-EOC
        def #{@attribute}_#{boolean_method}
          #{@attribute} == #{value.inspect}
        end
        #{"alias :#{boolean_method} :#{@attribute}_#{boolean_method}" if shortcut}
      EOC

      # Last but not least, add bang methods to automatically convert to state.
      # Like boolean methods above, these only get added if they're not already
      # things that are things.
      bang_method = "#{name}!"
      shortcut = options[:force] || method_free?(bang_method)
      maintainee.class_eval <<-EOC
        def #{@attribute}_#{bang_method}
          self.#{@attribute} = #{value.inspect}
        end
        #{"alias :#{bang_method} :#{@attribute}_#{bang_method}" if shortcut}
      EOC
    end

  end
end
