proceed = false
begin
  require 'rubygems'
  gem 'datamapper'
  require 'datamapper'
  proceed = true
rescue Gem::LoadError, LoadError
  puts 'Not testing DataMapper (unavailable)'
end

if proceed = false
  # Use load to have it evaluate the DataMapper extension logic again, in the event
  # that we've already done that with a previous test.
  load 'lib/maintain.rb'
  describe Maintain, "Datamapper::Resource" do
    it "should automatically be extended" do
      ActiveRecord::Base.should respond_to(:maintain)
    end
    describe "accessors" do
      before :each do
        ActiveRecord::Base.establish_connection({:adapter => 'sqlite3', :database => ':memory:', :pool => 5, :timeout => 5000})
        class ::ActiveMaintainTest < ActiveRecord::Base; end
        silence_stream(STDOUT) do
          ActiveRecord::Schema.define do
            create_table :active_maintain_tests, :force => true do |t|
              t.string :status
            end
          end
        end

        ActiveMaintainTest.maintain :status do
          state :new, :default => true
          state :old
          state :foo
          state :bar
          aggregate :everything, :as => [:new, :old, :foo, :bar]
          aggregate :fakes, :as => [:foo, :bar]
        end
      end

      it "should default to 'new'" do
        ActiveMaintainTest.new.status.should == 'new'
        ActiveMaintainTest.new.status.should == :new
      end

      it "should allow us to update its status to 'old'" do
        active_maintain_test = ActiveMaintainTest.new(:status => 'old')
        active_maintain_test.status.should == 'old'
        lambda {
          active_maintain_test.save!
        }.should_not raise_error
        ActiveMaintainTest.first.status.should == 'old'
      end

      it "should return the correct name when told to" do
        active_maintain_test = ActiveMaintainTest.create(:status => 'old')
        ActiveMaintainTest.first.status.name.should == 'old'
      end
    end

    describe "named_scopes" do
      it "should create named_scopes for all states" do
        ActiveMaintainTest.should respond_to(:old)
        ActiveMaintainTest.old.should respond_to(:each)
      end

      it "should create named_scopes for all aggregates" do
        ActiveMaintainTest.should respond_to(:everything)
        ActiveMaintainTest.everything.should respond_to(:each)
      end

      it "should return the correct collections on aggregates" do
        ActiveMaintainTest.destroy_all
        one = ActiveMaintainTest.create(:status => :foo)
        two = ActiveMaintainTest.create(:status => :bar)
        three = ActiveMaintainTest.create(:status => :new)
        four = ActiveMaintainTest.create(:status => :old)
        ActiveMaintainTest.fakes.should == [one, two]
        ActiveMaintainTest.everything.should == [one, two, three, four]
      end

    end
  end
end