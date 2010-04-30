# Tests on integer-specific functionality

require 'lib/maintain'

describe Maintain do
  before :each do
    class ::MaintainTest
      extend Maintain
    end
  end

  describe "integer" do
    before :each do
      MaintainTest.maintain :kind, :integer => true do
        state :man, 1
        state :woman, 2
        state :none, 3
      end
      @maintainer = MaintainTest.new
    end

    it "should return valid names, too" do
      @maintainer.kind = :woman
      @maintainer.kind.name.should == "woman"
    end

    it "should handle numbery strings" do
      @maintainer.kind = "3"
      @maintainer.none?.should be_true
    end
  end
end