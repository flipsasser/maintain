# Specs for assigning states

require 'lib/maintain'

describe Maintain do
  before :each do
    class MaintainTest
      attr_accessor :existant_attribute
      extend Maintain
    end
  end

  describe "setting" do
    describe "string states" do
      before :each do
        MaintainTest.maintain :state do
          state :new
          state :overdue
          state :closed
        end
        @maintainer = MaintainTest.new
      end

      it "should, you know, work" do
        @maintainer.state = :new
        @maintainer.state.should == :new
        @maintainer.state = 'new'
        @maintainer.state.should == :new
        @maintainer.state = 0
        @maintainer.state.should == :new
        @maintainer.state.name.should == "new"
        @maintainer.state = 'nada'
        @maintainer.state.should be_nil
      end
    end

    describe "integer states" do
      before :each do
        MaintainTest.maintain :state do
          state :new, 1
          state :overdue, 2
          state :closed, 3
        end
        @maintainer = MaintainTest.new
      end

      it "should, you know, work" do
        @maintainer.state = 1
        @maintainer.state.should == :new
        @maintainer.state = 'new'
        @maintainer.state.should == :new
        @maintainer.state = :new
        @maintainer.state.should == :new
      end
    end
  end
end