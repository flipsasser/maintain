# Basic class method specs

require 'spec_helper'
require 'maintain'

describe Maintain do
  before :each do
    class ::ModuleTest
      attr_accessor :existant_attribute
      extend Maintain
    end
  end

  # Basic overview / class methods
  it "extends things that include it" do
    ModuleTest.should respond_to(:maintain)
  end

  it "aliases the maintain method as `maintains`" do
    ModuleTest.should respond_to(:maintains)
  end

  it "accepts a block" do
    lambda {
      ModuleTest.maintain :non_existant_attribute do

      end
    }.should_not raise_error
  end

  it "stores a reference to all of the defined states in the class" do
    ModuleTest.maintain :non_existant_attribute
    ModuleTest.maintainers[:non_existant_attribute].should be_instance_of(Maintain::Definition)
  end

  it "defines accessors for non-existant attributes" do
    ModuleTest.maintain :non_existant_attribute
    ModuleTest.new.should respond_to('non_existant_attribute', 'non_existant_attribute=')
  end

  it "doesn't care about existant attributes" do
    lambda {
      ModuleTest.maintain :existant_attribute
    }.should_not raise_error
  end
end
