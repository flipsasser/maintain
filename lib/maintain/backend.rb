require 'maintain/backend/base'

module Maintain
  module Backend
    class << self
      def add(name, owner)
        classes[name.to_sym] = owner
        # Dig through the constant name to find if it exists
        modules = owner.split('::')
        if Object.const_defined?(modules.first) && owner = Object.const_get(modules.shift)
          while modules.length > 0
            owner = owner.const_get(modules.shift)
          end
          # If it exists, extend it with Maintain methods automatically
          owner.extend Maintain
        end
      end

      def build(back_end)
        back_end = back_end.to_s.split('_').map(&:capitalize).join('')
        if constants.include? back_end.to_s
          const_get(back_end.to_sym).new
        else
          begin
            back_end = const_missing(back_end)
            back_end.new
          rescue
          end
        end
      end

      def classes
        @classes ||= {}
      end

      def const_missing(constant)
        underscore_constant = constant.to_s.dup
        underscore_constant.gsub!(/::/, '/')
        underscore_constant.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
        underscore_constant.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
        underscore_constant.tr!("-", "_")
        underscore_constant.downcase!
        begin
          require("maintain/backend/#{underscore_constant}")
          const_get(constant)
        rescue
          super
        end
      end

      # Detect if we've loaded a backend for this class - that means if its
      # ancestors or parent classes include any of our back-end classes.
      def detect(owner)
        ancestors = owner.ancestors.map(&:to_s)
        # While owner does not refer to "Object"
        while owner.superclass
          ancestors.push(owner.to_s)
          owner = owner.superclass
        end
        classes.each do |back_end, class_name|
          if ancestors.include? class_name
            return back_end
          end
        end
        nil
      end
    end
  end
end
