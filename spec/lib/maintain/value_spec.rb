require 'spec_helper'
require 'maintain'

class ValueTest
  attr_accessor :existant_attribute
  extend Maintain
end

class ValueTestTwo
  def new?
    :i_existed_before_you_came_along
  end

  extend Maintain

  maintains :state, default: :new do
    state :new
    state :overdue
    state :closed
  end
end

describe Maintain::Value do

  describe "testing" do
    describe "string states" do

      before :all do
        ValueTest.maintain :state, default: :new do
          state :new
          state :overdue
          state :closed
        end
      end

      let(:value_test) { ValueTest.new }
      let(:value_test_2) { ValueTest.new }

      it "equality methods" do
        expect(value_test.state).to eq(:new)
        expect(value_test.state).to eq('new')
        expect(value_test.state).to eq(0)
        expect(value_test.state).to eq(value_test_2.state)
      end

      #describe "boolean methods" do
        #describe "on the accessor" do
          #it "should work" do
            #ValueTest.maintain :state, default: :new do
              #state :new
              #state :overdue
              #state :closed
            #end
            #maintainer = ValueTest.new
            #maintainer.state.new?).to be_true
            #maintainer.state.overdue?).to be_false
            #maintainer.state.closed?).to be_false
          #end

          #it "should not trap every method" do
            #maintainer = ValueTest.new
            #lambda {
              #maintainer.permissions.foobar?
            #}).to raise_error(NoMethodError)
          #end
        #end

        #describe "on the class itself" do
          #it "should work, too" do
            #ValueTest.maintain :state, default: :new do
              #state :new
              #state :overdue
              #state :closed
            #end
            #maintainer = ValueTest.new
            #maintainer.new?).to be_true
            #maintainer.overdue?).to be_false
            #maintainer.closed?).to be_false
          #end

          #it "should work with an attribute name prefix, too!" do
            #ValueTest.maintain :state, default: :new do
              #state :new
              #state :overdue
              #state :closed
            #end
            #maintainer = ValueTest.new
            #maintainer.state_new?).to be_true
            #maintainer.state_overdue?).to be_false
            #maintainer.state_closed?).to be_false
          #end

          #it "should not override pre-existing methods" do
            #ValueTestTwo.new.new?).to eq( :i_existed_before_you_came_along
          #end
        #end
      end

      #it "greater than method" do
        #ValueTest.maintain :state, default: :closed do
          #state :new
          #state :overdue
          #state :closed
        #end
        #value_test.state).to be > :overdue
        #value_test.state).to be > 'overdue'
        #value_test.state).to be > 1
      #end

      #it "less than method" do
        #value_test.state).to be < :overdue
        #value_test.state).to be < 'overdue'
        #value_test.state).to be < 1
      #end

      #it "greater-than-or-equal-to method" do
        #ValueTest.maintain :state, default: :closed do
          #state :new
          #state :overdue
          #state :closed
        #end
        #value_test.state).to be >= :overdue
        #value_test.state).to be >= 'overdue'
        #value_test.state).to be >= 1
        #value_test.state).to be >= :closed
        #value_test.state).to be >= 'closed'
        #value_test.state).to be >= 2
      #end

      #it "less-than-or-equal-to method" do
        #ValueTest.maintain :state, default: :new do
          #state :new
          #state :overdue
          #state :closed
        #end
        #value_test.state).to be <= :overdue
        #value_test.state).to be <= 'overdue'
        #value_test.state).to be <= 1
        #value_test.state).to be <= :new
        #value_test.state).to be <= 'new'
        #value_test.state).to be <= 0
      #end
    #end


    #describe "identity comparison" do
      #before :each do
        #ValueTest.maintain :state, default: :new do
          #state :new, 1
          #state :overdue, 2
          #state :closed, 3
        #end
        #value_test = ValueTest.new
      #end

       #it "should work with case statements" do
         #result = case value_test.state
         #when :overdue
           #nil
         #when :closed
           #nil
         #when :new
           #"foo"
         #else
           #nil
         #end
         #result).to eq( "foo"
       #end
    #end

    #describe "integer states" do
      #before :each do
        #ValueTest.maintain :state, default: :new do
          #state :new, 1
          #state :overdue, 2
          #state :closed, 3
        #end
        #value_test = ValueTest.new
      #end

      #it "equality methods" do
        #value_test.state).to eq( :new
        #value_test.state).to eq( 'new'
        #value_test.state).to eq( 1
        #value_test.state).to eq( ValueTest.new.state
      #end

      #it "greater than method" do
        #ValueTest.maintain :state, default: :closed do
          #state :new, 1
          #state :overdue, 2
          #state :closed, 3
        #end
        #value_test.state).to be > :overdue
        #value_test.state).to be > 'overdue'
        #value_test.state).to be > 1
      #end

      #it "less than method" do
        #value_test.state).to be < :overdue
        #value_test.state).to be < 'overdue'
        #value_test.state).to be < 2
      #end

      #it "greater-than-or-equal-to method" do
        #ValueTest.maintain :state, default: :closed do
          #state :new, 1
          #state :overdue, 2
          #state :closed, 3
        #end
        #value_test.state).to be >= :overdue
        #value_test.state).to be >= 'overdue'
        #value_test.state).to be >= 2
        #value_test.state).to be >= :closed
        #value_test.state).to be >= 'closed'
        #value_test.state).to be >= 3
      #end

      #it "less-than-or-equal-to method" do
        #ValueTest.maintain :state, default: :new do
          #state :new, 1
          #state :overdue, 2
          #state :closed, 3
        #end
        #value_test.state).to be <= :overdue
        #value_test.state).to be <= 'overdue'
        #value_test.state).to be <= 2
        #value_test.state).to be <= :new
        #value_test.state).to be <= 'new'
        #value_test.state).to be <= 1
      #end
    #end

  end

end
