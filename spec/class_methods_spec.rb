# Basic class method specs

require 'spec_helper'
require 'maintain'

describe Maintain do
  before :each do
    class ::MaintainTest
      attr_accessor :existant_attribute
      extend Maintain
    end
    MaintainTest.maintain :state do
      state :new
      state :overdue
      state :closed
    end
  end

  it "should provide a hash of key/value stores" do
    MaintainTest.state.should == [:new, :overdue, :closed]
  end

  it "should provide a hash of key/value stores in an Integer case, too" do
    MaintainTest.maintain :state_two, :integer => true do
      state :new, 1
      state :overdue, 2
      state :closed, 3
    end
    MaintainTest.state_two.should == [[:new, 1], [:overdue, 2], [:closed, 3]]
  end

  it "should not overwrite existing class methods" do
    def MaintainTest.foo
      "foo"
    end

    MaintainTest.maintain :foo do
      state :new
      state :overdue
      state :closed
    end
    MaintainTest.foo.should == "foo"
    MaintainTest.maintain_foo.should == [:new, :overdue, :closed]
  end
end