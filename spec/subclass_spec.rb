# Basic class method specs

require 'spec_helper'
require 'maintain'

describe Maintain do
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