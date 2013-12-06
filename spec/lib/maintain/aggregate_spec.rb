# Specs for the aggregate method

require 'spec_helper'
require 'maintain'

class AggregateTest
  extend Maintain

  AggregateTest.maintains :state do
    state :old
    state :new
    state :borrowed
    state :blue
    aggregate :b_words, [:borrowed, :blue]
  end
end

describe Maintain::Aggregate do

  let(:aggregate_test) { AggregateTest.new }

  it "creates boolean methods" do
    expect(aggregate_test).to respond_to(:b_words?)
  end

  it "returns true if one of the aggregate states are met" do
    aggregate_test.state = :new
    expect(aggregate_test.b_words?).to be_false
    aggregate_test.state = :blue
    expect(aggregate_test.b_words?).to be_true
  end

end
