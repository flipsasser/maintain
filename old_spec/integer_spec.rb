# Tests on integer-specific functionality

require 'spec_helper'
require 'maintain'

describe Maintain do
  before :each do
    class ::MaintainTest
      extend Maintain
    end
  end

  describe "integer" do
    before :each do
      MaintainTest.maintain :kind, integer: true do
        state :man, 1
        state :woman, 2, default: true
        state :none, 3
      end
      @maintainer = MaintainTest.new
    end

    it "should handle numbery strings" do
      @maintainer.kind = "3"
      @maintainer.none?.should be_true
    end

    it "should handle defaults just fine" do
      @maintainer.woman?.should be_true
    end

    it "should return valid names, too" do
      @maintainer.kind = :woman
      @maintainer.kind.should == 2
      @maintainer.kind.name.should == "woman"
    end
  end
end
