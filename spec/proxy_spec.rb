# Comparing state values

require 'lib/maintain'

describe Maintain do
  before :each do
    class MaintainTest
      attr_accessor :existant_attribute
      include Maintain
    end

  end

  describe "`class` calls" do
    it "should return NilClass for states without a value" do
      MaintainTest.maintain :state do
        state :new
        state :overdue
        state :closed
      end
      MaintainTest.new.state.class.should == NilClass
    end

    it "should return Symbol for states with a string column" do
      MaintainTest.maintain :state do
        state :new
        state :overdue
        state :closed
      end
      maintain_test = MaintainTest.new
      maintain_test.state = :overdue
      maintain_test.state.class.should == Symbol
    end

    it "should return Integer for states with an integer column" do
      MaintainTest.maintain :state do
        state :new, 0
        state :overdue, 1
        state :closed, 2
      end
      maintain_test = MaintainTest.new
      maintain_test.state = :closed
      maintain_test.state.class.should == Fixnum
    end
  end

  describe "`inspect` calls" do
    it "should return 'nil' for states without a default" do
      MaintainTest.maintain :state do
        state :new
        state :overdue
        state :closed
      end
      MaintainTest.new.state.inspect.should == 'nil'
    end

    it "should return ':new' for a state with a default value of :new" do
      MaintainTest.maintain :state, :default => :new do
        state :new
        state :overdue
        state :closed
      end
      MaintainTest.new.state.inspect.should == ':new'
    end

    it "should return '2' for a state with a default value of :new, 2 and an :integer column" do
      MaintainTest.maintain :state, :default => :new do
        state :new, 2
        state :overdue, 5
        state :closed, 22
      end
      MaintainTest.new.state.inspect.should == '2'
    end
  end

  describe "`nil?` calls" do
    it "should return true for states without a default" do
      MaintainTest.maintain :state do
        state :new
        state :overdue
        state :closed
      end
      MaintainTest.new.state.nil?.should be_true
    end

    it "should return false for states with a default" do
      MaintainTest.maintain :state, :default => :new do
        state :new
        state :overdue
        state :closed
      end
      MaintainTest.new.state.nil?.should_not be_true
    end
  end

  describe "`to_s` calls" do
    it "should return '' for states without a default" do
      MaintainTest.maintain :state do
        state :new
        state :overdue
        state :closed
      end
      MaintainTest.new.state.to_s.should == ''
    end

    it "should return 'new' for a state with a default value of :new" do
      MaintainTest.maintain :state, :default => :new do
        state :new
        state :overdue
        state :closed
      end
      MaintainTest.new.state.to_s.should == 'new'
    end

    it "should return '2' for a state with a default value of :new, 2 and an :integer column" do
      MaintainTest.maintain :state, :default => :new do
        state :new, 2
        state :overdue, 5
        state :closed, 22
      end
      MaintainTest.new.state.to_s.should == '2'
    end
  end
end