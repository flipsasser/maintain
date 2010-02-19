# Basic class method specs

require 'lib/maintain'

describe Maintain do
  before :each do
    class MaintainTest
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
  end
end