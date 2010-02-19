# Configuration point number one: setting and configuring states

require 'lib/maintain'

describe Maintain do
  before :each do
    class MaintainTest
      attr_accessor :existant_attribute
      extend Maintain
    end
  end

  describe "defining states" do
    it "should be possible" do
      lambda {
        MaintainTest.maintain :existant_attribute do
          state :new
        end
      }.should_not raise_error
      MaintainTest.new.existant_attribute.should be_nil
    end

    it "should support default values" do
      MaintainTest.maintain :existant_attribute do
        state :new, :default => true
      end
      MaintainTest.new.existant_attribute.should == :new
    end

    it "should support integer values" do
      MaintainTest.maintain :existant_attribute do
        state :new, 1, :default => true
      end
      MaintainTest.new.existant_attribute.should == 1
    end

    it "should provide accessor methods on the Maintain::Maintainer class for state values" do
      maintainer = MaintainTest.maintain :permissions, :bitmask => true do
        state :edit, 1
        state :delete, 2
        state :update, 3
      end
      maintainer.update.should == 8
    end

    it "should not trap all methods when providing accessor methods for state values" do
      maintainer = MaintainTest.maintain :permissions, :bitmask => true do
        state :edit, 1
        state :delete, 2
        state :update, 3
      end
      lambda {
        maintainer.i_probably_dont_exist
      }.should raise_error(NoMethodError)
    end

    describe "as bitmask" do
      it "should calculate a base-2 compatible integer" do
        maintainer = MaintainTest.maintain :permissions, :bitmask => true do
          state :edit, 1
          state :delete, 2
          state :update, 3
        end
        maintainer.update.should == 8
      end

      it "should auto-increment bitmask column values (but dangerously!)" do
        maintainer = MaintainTest.maintain :permissions, :bitmask => true do
          state :edit
          state :delete
          state :update
        end
        maintainer.edit.should == 1
        maintainer.delete.should == 2
        maintainer.update.should == 4
      end
    end
  end
end