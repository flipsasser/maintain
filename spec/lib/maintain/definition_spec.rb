require 'spec_helper'
require 'maintain'

describe Maintain::Definition, "class methods" do
  before :each do
    class ::DefinitionClassMethodsTest
      attr_accessor :existant_attribute
      extend Maintain
    end
    DefinitionClassMethodsTest.maintain :state do
      state :new
      state :overdue
      state :closed
    end
  end

  it "should provide a hash of key/value stores" do
    DefinitionClassMethodsTest.state.should == [[:new, 'new'], [:overdue, 'overdue'], [:closed, 'closed']]
  end

  it "should provide a hash of key/value stores in an Integer case, too" do
    DefinitionClassMethodsTest.maintain :state_two, integer: true do
      state :new, 1
      state :overdue, 2
      state :closed, 3
    end
    DefinitionClassMethodsTest.state_two.should == [[:new, 1], [:overdue, 2], [:closed, 3]]
  end

  it "should not overwrite existing class methods" do
    def DefinitionClassMethodsTest.foo
      "foo"
    end

    DefinitionClassMethodsTest.maintain :foo do
      state :new
      state :overdue
      state :closed
    end
    DefinitionClassMethodsTest.foo.should == "foo"
    DefinitionClassMethodsTest.maintain_foo.should == [[:new, 'new'], [:overdue, 'overdue'], [:closed, 'closed']]
  end
end

describe Maintain::Definition, "subclassing" do
  before :each do
    class ::MaintainSubclassTest
      attr_accessor :existant_attribute
      extend Maintain
    end

    class ::MaintainSubclassTestSubclass < ::MaintainSubclassTest; end
  end

  it "should inherit maintainers from parent classes" do
    MaintainSubclassTest.maintain :status do
      state :new
      state :old
    end
    MaintainSubclassTestSubclass.maintainers[:status].should_not be_nil
  end

  it "should not propagate maintainers up the class system" do
    MaintainSubclassTest.maintain :status do
      state :new
      state :old
    end
    MaintainSubclassTestSubclass.maintain :foo do
      state :bar
      state :baz
    end
    MaintainSubclassTest.maintainers[:foo].should be_nil
    MaintainSubclassTestSubclass.maintainers[:status].should_not be_nil
  end
end
