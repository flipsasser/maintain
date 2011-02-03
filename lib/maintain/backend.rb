require 'maintain/backend/base'

module Maintain
  module Backend
    class << self
      def build(back_end, maintainer)
        back_end = back_end.split('_').map(&:capitalize).join('')
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
    end
  end
end
