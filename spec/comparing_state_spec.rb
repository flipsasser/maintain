# Comparing state values

require 'lib/maintain'

describe Maintain do
  before :each do
    class MaintainTest
      attr_accessor :existant_attribute
      extend Maintain
    end
  end

  describe "testing" do
    describe "string states" do
      before :each do
        MaintainTest.maintain :state, :default => :new do
          state :new
          state :overdue
          state :closed
        end
        @maintainer = MaintainTest.new
        @other_maintainer = MaintainTest.new
      end

      it "equality methods" do
        @maintainer.state.should == :new
        @maintainer.state.should == 'new'
        @maintainer.state.should == 0
        @maintainer.state.should == MaintainTest.new.state
        @maintainer.state.should == @other_maintainer.state
      end

      describe "boolean methods" do
        describe "on the accessor" do
          it "should work" do
            MaintainTest.maintain :state, :default => :new do
              state :new
              state :overdue
              state :closed
            end
            maintainer = MaintainTest.new
            maintainer.state.new?.should be_true
            maintainer.state.overdue?.should be_false
            maintainer.state.closed?.should be_false
          end

          it "should not trap every method" do
            maintainer = MaintainTest.new
            lambda {
              maintainer.permissions.foobar?
            }.should raise_error(NoMethodError)
          end
        end

        describe "on the class itself" do
          it "should work, too" do
            MaintainTest.maintain :state, :default => :new do
              state :new
              state :overdue
              state :closed
            end
            maintainer = MaintainTest.new
            maintainer.state.new?.should be_true
            maintainer.state.overdue?.should be_false
            maintainer.state.closed?.should be_false
          end

          it "should not override pre-existing methods" do
            class MaintainTestTwo
              def new?
                :i_existed_before_you_came_along
              end
              extend Maintain
              maintains :state, :default => :new do
                state :new
                state :overdue
                state :closed
              end
            end
            MaintainTestTwo.new.new?.should == :i_existed_before_you_came_along
          end
        end
      end

      it "greater than method" do
        MaintainTest.maintain :state, :default => :closed do
          state :new
          state :overdue
          state :closed
        end
        @maintainer.state.should be > :overdue
        @maintainer.state.should be > 'overdue'
        @maintainer.state.should be > 1
      end

      it "less than method" do
        @maintainer.state.should be < :overdue
        @maintainer.state.should be < 'overdue'
        @maintainer.state.should be < 1
      end

      it "greater-than-or-equal-to method" do
        MaintainTest.maintain :state, :default => :closed do
          state :new
          state :overdue
          state :closed
        end
        @maintainer.state.should be >= :overdue
        @maintainer.state.should be >= 'overdue'
        @maintainer.state.should be >= 1
        @maintainer.state.should be >= :closed
        @maintainer.state.should be >= 'closed'
        @maintainer.state.should be >= 2
      end

      it "less-than-or-equal-to method" do
        MaintainTest.maintain :state, :default => :new do
          state :new
          state :overdue
          state :closed
        end
        @maintainer.state.should be <= :overdue
        @maintainer.state.should be <= 'overdue'
        @maintainer.state.should be <= 1
        @maintainer.state.should be <= :new
        @maintainer.state.should be <= 'new'
        @maintainer.state.should be <= 0
      end
    end

    describe "integer states" do
      before :each do
        MaintainTest.maintain :state, :default => :new do
          state :new, 1
          state :overdue, 2
          state :closed, 3
        end
        @maintainer = MaintainTest.new
      end

      it "equality methods" do
        @maintainer.state.should == :new
        @maintainer.state.should == 'new'
        @maintainer.state.should == 1
        @maintainer.state.should == MaintainTest.new.state
      end

      it "greater than method" do
        MaintainTest.maintain :state, :default => :closed do
          state :new, 1
          state :overdue, 2
          state :closed, 3
        end
        @maintainer.state.should be > :overdue
        @maintainer.state.should be > 'overdue'
        @maintainer.state.should be > 1
      end

      it "less than method" do
        @maintainer.state.should be < :overdue
        @maintainer.state.should be < 'overdue'
        @maintainer.state.should be < 2
      end

      it "greater-than-or-equal-to method" do
        MaintainTest.maintain :state, :default => :closed do
          state :new, 1
          state :overdue, 2
          state :closed, 3
        end
        @maintainer.state.should be >= :overdue
        @maintainer.state.should be >= 'overdue'
        @maintainer.state.should be >= 2
        @maintainer.state.should be >= :closed
        @maintainer.state.should be >= 'closed'
        @maintainer.state.should be >= 3
      end

      it "less-than-or-equal-to method" do
        MaintainTest.maintain :state, :default => :new do
          state :new, 1
          state :overdue, 2
          state :closed, 3
        end
        @maintainer.state.should be <= :overdue
        @maintainer.state.should be <= 'overdue'
        @maintainer.state.should be <= 2
        @maintainer.state.should be <= :new
        @maintainer.state.should be <= 'new'
        @maintainer.state.should be <= 1
      end
    end
  end
end