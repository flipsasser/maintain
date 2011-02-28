# Basic class method specs

require 'lib/maintain'

describe Maintain do
  before :each do
    class ::MaintainTest
      attr_accessor :existant_attribute
      extend Maintain
    end

    class ::MaintainTestSubclass < ::MaintainTest; end
  end

  it "should inherit maintainers from parent classes" do
    MaintainTest.maintain :status do
      state :new
      state :old
    end
    MaintainTestSubclass.maintainers[:status].should_not be_nil
  end

  it "should not propagate maintainers up the class system" do
    MaintainTest.maintain :status do
      state :new
      state :old
    end
    MaintainTestSubclass.maintain :foo do
      state :bar
      state :baz
    end
    MaintainTest.maintainers[:foo].should be_nil
    MaintainTestSubclass.maintainers[:status].should_not be_nil
  end

  
end