# Specs for the aggregate method

require 'spec_helper'
require 'maintain'

describe Maintain, "aggregates" do
  before :each do
    class ::AggregateTest
      extend Maintain
    end
  end

  it "should allow me to define an aggregate" do
    lambda {
      AggregateTest.maintains :state do
        state :old
        state :new
        state :borrowed
        state :blue
        aggregate :b_words, [:borrowed, :blue]
      end
    }.should_not raise_error
  end

  it "should create boolean methods" do
    AggregateTest.new.should respond_to(:b_words?)
  end

  it "should return true if one of the states is met in the boolean" do
    maintain = AggregateTest.new
    maintain.state = :new
    maintain.b_words?.should be_false
    maintain.state = :blue
    maintain.b_words?.should be_true
  end
end
