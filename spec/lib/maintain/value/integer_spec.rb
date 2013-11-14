require 'spec_helper'
require 'maintain'

class IntegerTest
  extend Maintain
  maintain :kind, integer: true do
    state :man, 1
    state :woman, 2, default: true
    state :other, 3
  end
end

describe Maintain::Value::Integer do

  let(:integer_test) { IntegerTest.new }

  it "handles numbery strings" do
    integer_test.kind = "3"
    expect(integer_test.other?).to be_true
  end

  it "handles defaults just fine" do
    expect(integer_test.woman?).to be_true
  end

  it "returns valid names, too" do
    integer_test.kind = :other
    expect(integer_test.kind).to eq(3)
    expect(integer_test.kind.name).to eq("other")
  end

end
