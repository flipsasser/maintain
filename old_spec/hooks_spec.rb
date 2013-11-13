# Hooks on state entrance / exit. Needs more attention.

require 'spec_helper'
require 'maintain'

describe Maintain, "hooks" do
  before :each do
    class ::MaintainTest
      extend Maintain
    end
  end

  it "should allow me to hook into entry and exit" do
    lambda {
      MaintainTest.maintain :state do
        state :new, enter: :new_entered
        state :old, enter: :old_entered
        on :enter, :new, :new_entered
        on :exit, :old do
          self.old_entered
        end
      end
    }.should_not raise_error
  end

  it "should execute hooks when states are entered and exited" do
    MaintainTest.maintain :state do
      state :new
      state :old
      on :enter, :new, :new_entered
      on :enter, :old do
        self.old_entered
      end
    end

    maintain = MaintainTest.new
    maintain.should_receive(:new_entered)
    maintain.state = :new
    maintain.should_receive(:old_entered).once
    maintain.state = :old
    maintain.state = :old
  end

  describe "guarding" do
    it "should prevent hooks from running when they return false" do
      MaintainTest.maintain :state do
        state :new
        state :old
        on :enter, :new, :new_entered, if: :run_hook?
      end

      maintain = MaintainTest.new
      def maintain.run_hook?
        false
      end
      maintain.should_not_receive(:new_entered)
      maintain.state = :new
      maintain.state = :old
      maintain.state = :old
    end
  end
end
