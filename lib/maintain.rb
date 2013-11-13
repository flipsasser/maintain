# encoding: UTF-8
$LOAD_PATH.unshift File.join(File.dirname(__FILE__))
require 'maintain/backend'

module Maintain
  autoload(:Aggregate, 'maintain/aggregate')
  autoload(:Definition, 'maintain/definition')
  autoload(:State, 'maintain/state')
  autoload(:Utils, 'maintain/utils')
  autoload(:Value, 'maintain/value')

  # The core class method of Maintain. Basic usage is:
  #
  #   maintain :state do
  #     state :new, default: true
  #     state :expired, enter: :expire_children
  #     state :reopened, exit: lambda { children.each(&:reopen) }
  #     aggregate :accessible, as: [:new, :reopened]
  #   end
  #
  # It also supports more complex configuration options, like bitmask columns
  # and integer values (for performance and portability)
  #
  #   maintain :permissions, bitmask: true do
  #     state :edit, 1
  #     state :delete, 2
  #     state :manage, 3
  #   end
  #
  # This method is aliased as `maintains` with the intention of allowing
  # developers to code imperatively ("maintain, damn you!") or descriptively
  # ("it maintains, man")
  def maintain(attribute, options = {}, &block)
    attribute = attribute.to_sym
    options[:back_end] ||= Maintain::Backend.detect(self)

    definition = Maintain::Definition.new(self, attribute, options)
    if block_given?
      definition.interface.instance_eval(&block)
    end
    definition.define_methods!
    maintainers[attribute] = definition
  end

  alias :maintains :maintain

  def maintainers #:nodoc:
    @maintainers ||= {}.tap do |maintainers|
      superk = superclass
      while superk.respond_to?(:maintainers)
        maintainers.merge!(superk.maintainers)
        superk = superk.superclass
      end
      maintainers
    end
  end

  if !const_defined?(:VERSION)
    version_path = File.join(File.dirname(__FILE__), '..', 'VERSION')
    if File.file?(version_path)
      VERSION = File.read(version_path).strip
    else
      VERSION = '0.3.0'
    end
  end
end

Maintain::Backend.add(:active_record, 'ActiveRecord::Base')
Maintain::Backend.add(:data_mapper, 'DataMapper::Resource')
