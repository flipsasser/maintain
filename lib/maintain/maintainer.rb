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

  end
end
