require 'spec_helper'
require 'maintain'

class ModuleTest
  attr_accessor :existant_attribute
  extend Maintain
end

describe Maintain, 'class methods' do

  it "extends things that include it" do
    expect(ModuleTest).to respond_to(:maintain)
  end

  it "aliases the maintain method as `maintains`" do
    expect(ModuleTest).to respond_to(:maintains)
  end

  it "accepts a block" do
    expect(lambda {
      ModuleTest.maintain(:non_existant_attribute) { }
    }).not_to raise_error
  end

  it "stores a reference to the defined states" do
    ModuleTest.maintain :non_existant_attribute
    definition = ModuleTest.maintainers[:non_existant_attribute]
    expect(definition).to be_instance_of(Maintain::Definition)
  end

  it "defines accessors for non-existant attributes" do
    ModuleTest.maintain :non_existant_attribute
    expect(ModuleTest.new).to respond_to('non_existant_attribute', 'non_existant_attribute=')
  end

  it "overwrites existant attributes" do
    expect(lambda {
      ModuleTest.maintain :existant_attribute
    }).not_to raise_error
  end

end

class MaintainSubclassTest
  attr_accessor :existant_attribute
  extend Maintain

  maintain :status do
    state :new
    state :old
  end
end

class MaintainSubclassTestSubclass < MaintainSubclassTest
  maintain :foo do
    state :bar
    state :baz
  end
end

describe Maintain, 'subclassing' do

  it "inherits maintainers from super classes" do
    expect(MaintainSubclassTestSubclass.maintainers[:status]).not_to be_nil
  end

  it "does not propagate maintainers to super classes" do
    expect(MaintainSubclassTest.maintainers[:foo]).to be_nil
    expect(MaintainSubclassTestSubclass.maintainers[:status]).not_to be_nil
  end

end
