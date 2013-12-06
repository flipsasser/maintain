require 'spec_helper'
require 'maintain'

class DefinitionInterfaceTest
  attr_accessor :existant_attribute
  extend Maintain

  maintain :permissions, bitmask: true do
    state :edit, 1
    state :delete, 2
    state :update, 3
  end
end

describe Maintain::Definition::Interface do

  let(:definition) { DefinitionInterfaceTest.maintainers[:permissions] }
  let(:definition_test) { DefinitionInterfaceTest.new }

  it "defines a maintainer in a block" do
    expect(lambda {
      DefinitionInterfaceTest.maintain :existant_attribute do
        state :new
      end
    }).not_to raise_error
    expect(definition_test.existant_attribute).to be_nil
  end

  it "supports default values" do
    DefinitionInterfaceTest.maintain :existant_attribute do
      state :new, default: true
    end
    expect(definition_test.existant_attribute).to eq(:new)
  end

  it "supports default integer values" do
    DefinitionInterfaceTest.maintain :existant_attribute do
      state :new, 1, default: true
    end
    expect(definition_test.existant_attribute).to eq(1)
  end

  it "adds accessor methods on the for state values" do
    expect(definition.update).to eq(8)
  end

  it "does not trap EVERY method" do
    expect(lambda {
      definition.i_probably_dont_exist
    }).to raise_error(NoMethodError)
  end

  it "passes valid methods to the actual value object" do
    DefinitionInterfaceTest.maintain :existant_attribute do
      state :new, default: true
    end
    expect(definition_test.existant_attribute.length).to eq(3)
  end

  describe "as a bitmask" do
    it "calculates a base-2 compatible integer" do
      expect(definition.update).to eq(8)
    end

    it "auto-increments bitmask column values (but dangerously!)" do
      DefinitionInterfaceTest.maintain :permissions, bitmask: true do
        state :edit
        state :delete
        state :update
      end
      expect(definition.edit).to eq(1)
      expect(definition.delete).to eq(2)
      expect(definition.update).to eq(4)
    end
  end

end
