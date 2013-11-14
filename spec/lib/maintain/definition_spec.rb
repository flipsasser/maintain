#require 'spec_helper'
require 'maintain'

class DefinitionClassMethodsTest

  attr_accessor :existant_attribute
  extend Maintain

  maintain :state do
    state :new
    state :overdue
    state :closed
  end

  maintain :state_two, integer: true do
    state :new, 1
    state :overdue, 2
    state :closed, 3
  end

end

describe Maintain::Definition, "class methods" do

  let(:string_hash) do
    [
      [:new, 'new'],
      [:overdue, 'overdue'],
      [:closed, 'closed']
    ]
  end

  let(:integer_hash) do
    [
      [:new, 1],
      [:overdue, 2],
      [:closed, 3]
    ]
  end

  it "provides a hash of key/value stores" do
    expect(DefinitionClassMethodsTest.state).to eq(string_hash)
  end

  it "provides a hash of key/value stores in an Integer case, too" do

    expect(DefinitionClassMethodsTest.state_two).to eq(integer_hash)
  end

  it "does not overwrite existing class methods" do
    def DefinitionClassMethodsTest.foo
      "foo"
    end

    DefinitionClassMethodsTest.maintain :foo do
      state :new
      state :overdue
      state :closed
    end
    expect(DefinitionClassMethodsTest.foo).to eq('foo')
    expect(DefinitionClassMethodsTest.maintain_foo).to eq(string_hash)
  end

end
