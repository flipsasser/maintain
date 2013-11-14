require 'spec_helper'
require 'maintain'

class BitmaskTest
  extend Maintain
end

describe Maintain::Value::Bitmask do

  let(:bitmask_test) { BitmaskTest.new }

  it "allows for multiple defaults" do
    BitmaskTest.maintain :permissions, bitmask: true do
      state :edit, 1, default: true
      state :delete, 2, default: true
      state :update, 3
    end
    expect(bitmask_test.permissions.edit?).to be_true
    expect(bitmask_test.permissions.delete?).to be_true
    expect(bitmask_test.permissions.update?).not_to be_true
  end

  describe "accessor methods" do

    before :all do
      BitmaskTest.maintain :permissions, bitmask: true do
        state :edit, 1
        state :delete, 2
        state :update, 3
      end
    end

    it "default to zero" do
      expect(bitmask_test.permissions).to eq(0)
    end

    it "supports a `state?' syntax" do
      bitmask_test.permissions = :edit
      expect(bitmask_test.permissions.edit?).to be_true
      expect(bitmask_test.permissions.delete?).not_to be_true
      bitmask_test.permissions = [:update, :delete]
      expect(bitmask_test.permissions.edit?).not_to be_true
      expect(bitmask_test.permissions.delete?).to be_true
      expect(bitmask_test.permissions.update?).to be_true
    end

    it "can query state directly on the object" do
      bitmask_test.permissions = :edit
      expect(bitmask_test.edit?).to be_true
      expect(bitmask_test.delete?).not_to be_true
    end

    it "should not trap every method" do
      expect(lambda {
        bitmask_test.permissions.foobar?
      }).to raise_error(NoMethodError)
    end

    it "is enumerable" do
      bitmask_test.permissions = %w(edit update)
      expect(bitmask_test.permissions.to_a).to eq(%w(edit update).map(&:to_sym))
      expect(bitmask_test.permissions).to respond_to(:each)
      expect(bitmask_test.permissions.select {|permission| permission == :edit}).to eq([:edit])
    end
  end

  describe "setter methods" do
    it "can set individial states" do
      bitmask_test.permissions = :edit
      expect(bitmask_test.permissions).to eq([:edit])
      expect(bitmask_test.permissions).to eq(2)
    end

    it "can set an of array states" do
      bitmask_test.permissions = [:edit, :delete]
      expect(bitmask_test.permissions).to eq(6)
      expect(bitmask_test.permissions).not_to eq(7)
      expect(bitmask_test.permissions).to eq([:edit, :delete])
    end

    it "supports `bang!' syntax for turning on states" do
      bitmask_test.permissions = nil
      bitmask_test.permissions = []
      expect(bitmask_test.permissions).to eq(0)
      bitmask_test.permissions.edit!
      expect(bitmask_test.permissions.edit?).to be_true
      expect(bitmask_test.permissions.delete?).not_to be_true
      bitmask_test.permissions.update!
      expect(bitmask_test.permissions.edit?).to be_true
      expect(bitmask_test.permissions.edit?).to be_true
      expect(bitmask_test.permissions.delete?).not_to be_true
      expect(bitmask_test.permissions.update?).to be_true
    end
  end
end
