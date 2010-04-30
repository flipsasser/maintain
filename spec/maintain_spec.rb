# Basic class method specs

require 'lib/maintain'

describe Maintain do
  before :each do
    class ::MaintainTest
      attr_accessor :existant_attribute
      extend Maintain
    end
  end

  # Basic overview / class methods
  it "should extend things that include it" do
    MaintainTest.should respond_to(:maintain)
  end

  it "should alias the maintain method as `maintains`" do
    MaintainTest.should respond_to(:maintains)
  end

  it "should accept a block" do
    lambda {
      MaintainTest.maintain :non_existant_attribute do
        
      end
    }.should_not raise_error
  end

  it "should store a reference to all of the defined states in the class" do
    MaintainTest.maintain :non_existant_attribute
    MaintainTest.send(:maintainers)[:non_existant_attribute].should be_instance_of(Maintain::Maintainer)
  end

  it "should define accessors for non-existant attributes" do
    MaintainTest.maintain :non_existant_attribute
    MaintainTest.new.should respond_to('non_existant_attribute', 'non_existant_attribute=')
  end

  it "shouldn't care about existant attributes" do
    lambda {
      MaintainTest.maintain :existant_attribute
    }.should_not raise_error
  end
end