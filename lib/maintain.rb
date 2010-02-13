module Maintain
  autoload(:Methods, 'lib/maintain/methods')
  autoload(:State, 'lib/maintain/state')
  autoload(:StateValue, 'lib/maintain/state_value')
  autoload(:BitmaskStateValue, 'lib/maintain/bitmask_state_value')
  autoload(:IntegerStateValue, 'lib/maintain/integer_state_value')

  def self.included(base)
    base.extend Maintain::Methods
  end
end