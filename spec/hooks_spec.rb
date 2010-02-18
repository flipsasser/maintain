# Comparing state values

require 'lib/maintain'

describe Maintain, "hooks" do
  before :each do
    class MaintainTest
      include Maintain
    end
  end

  it "should allow me to hook into entry and exit" do
    lambda {
      MaintainTest.maintain :state do
        state :new, :enter => :new_entered
        state :old, :enter => :old_entered
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
      on :exit, :old do
        self.old_entered
      end
    end

    maintain = MaintainTest.new
    maintain.should_receive(:new_entered)
    maintain.state = :new
  end

end