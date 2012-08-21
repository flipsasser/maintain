# Some specs to check against ActiveRecord conflicts. Rails tends to blow
# shit up when you build it outside of Rails. We'll see how this goes...

proceed = false
begin
  require 'rubygems'
  gem 'activerecord', '>= 2.3.5'
  require 'active_record'
  require 'logger'
  proceed = true
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  ActiveRecord::Base.logger.level = Logger::Severity::UNKNOWN
rescue Gem::LoadError, LoadError
  puts 'Not testing ActiveRecord (unavailable)'
end

if proceed
  # Use load to have it evaluate the ActiveRecord::Base extension logic again, in the event
  # that we've already done that with a previous test.
  load 'maintain.rb'
  describe Maintain, "ActiveRecord::Base" do
    it "should automatically be extended" do
      ActiveRecord::Base.should respond_to(:maintain)
    end

    before :each do
      ActiveRecord::Base.establish_connection({:adapter => 'sqlite3', :database => ':memory:', :pool => 5, :timeout => 5000})
      class ::ActiveMaintainTest < ActiveRecord::Base; end
      silence_stream(STDOUT) do
        ActiveRecord::Schema.define do
          create_table :active_maintain_tests, :force => true do |t|
            t.string :status
            t.integer :permissions
          end
        end
      end
    end

    describe "accessors" do
      before :all do
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

      it "should allow us to update statuses using update_attributes" do
        active_maintain_test = ActiveMaintainTest.new
        active_maintain_test.update_attributes(:status => :bar)
        ActiveMaintainTest.first.status.should == :bar
      end

      it "should allow us to update statuses using update_attribute" do
        active_maintain_test = ActiveMaintainTest.new
        active_maintain_test.update_attribute(:status, :bar)
        ActiveMaintainTest.first.status.should == :bar
      end

      it "should return the correct name when told to" do
        active_maintain_test = ActiveMaintainTest.create(:status => 'old')
        ActiveMaintainTest.first.status.name.should == 'old'
      end
    end

    describe "bitmasks" do
      before :all do
        ActiveMaintainTest.maintain :permissions, :bitmask => true do
          state :add, 0
          state :delete, 1
          state :foo, 2
          state :bar, 3

          aggregate :everything, :as => [:new, :old, :foo, :bar]
          aggregate :fakes, :as => [:foo, :bar]
        end
      end

      it "should allow me to set a bitmask value" do
        active_maintain_test = ActiveMaintainTest.create(:permissions => 'add')
        ActiveMaintainTest.last.permissions.add?.should be_true
      end

      it "should allow me to set multiple bitmask values" do
        active_maintain_test = ActiveMaintainTest.create(:permissions => ['add', 'delete'])
        ActiveMaintainTest.last.permissions.add?.should be_true
        ActiveMaintainTest.last.permissions.delete?.should be_true
      end

      it "should allow me to set a blank string as bitmask values" do
        active_maintain_test = ActiveMaintainTest.create(:permissions => '')
        ActiveMaintainTest.last.permissions.should == 0
      end

      it "should allow me to set an empty array as bitmask values" do
        active_maintain_test = ActiveMaintainTest.create(:permissions => [])
        ActiveMaintainTest.last.permissions.should == 0
      end

      it "should allow me to set an array with empty strings as bitmask values" do
        active_maintain_test = ActiveMaintainTest.create(:permissions => [''])
        ActiveMaintainTest.last.permissions.should == 0
      end
    end

    describe "hooks" do
      before :all do
        ActiveMaintainTest.maintain :status do
          state :new, :default => true
          state :old
          state :foo
          state :bar
          aggregate :everything, :as => [:new, :old, :foo, :bar]
          aggregate :fakes, :as => [:foo, :bar]

          on :enter, :old, :do_something
          on :exit, :foo, :do_something_else
          on :enter, :bar, lambda { hello! }, :if => :run_hello?
          on :exit, :bar, lambda { hello! }, :unless => :run_hello?
          on :enter, :bar, :show_my_id, :after => true
        end

        ActiveMaintainTest.class_eval do
          def do_something
            # Do... something?
          end

          def do_something_else
            # Do something else!
          end

          def hello!
            
          end

          def run_hello!
            @run_hello = !@run_hello# ? false : true
          end

          def run_hello?
            @run_hello
          end

          def show_my_id
            puts id
          end
        end
      end

      it "should not send hooks immediately on attribute setting" do
        active_maintain_test = ActiveMaintainTest.new
        active_maintain_test.should_not_receive(:do_something)
        active_maintain_test.status = :old
      end

      it "should send hooks when a record is saved" do
        active_maintain_test = ActiveMaintainTest.new
        active_maintain_test.should_receive(:do_something)
        active_maintain_test.status = :old
        active_maintain_test.save
      end

      it "should send :exit hooks when a record is saved after a value is exited from" do
        active_maintain_test = ActiveMaintainTest.new
        active_maintain_test.status = :foo
        active_maintain_test.save
        active_maintain_test.should_receive(:do_something_else)
        active_maintain_test.status = :new
        active_maintain_test.save
      end

      it "should not run the :bar enter hook if run_hello? returns false" do
        active_maintain_test = ActiveMaintainTest.new
        active_maintain_test.should_not_receive(:hello!)
        active_maintain_test.status = :bar
        active_maintain_test.save
      end

      it "should run the :bar enter hook if run_hello? returns true" do
        active_maintain_test = ActiveMaintainTest.new
        active_maintain_test.run_hello!
        active_maintain_test.should_receive(:hello!)
        active_maintain_test.status = :bar
        active_maintain_test.save
      end

      it "should not run the :bar exit hook if run_hello? returns true" do
        active_maintain_test = ActiveMaintainTest.create(:status => :bar)
        active_maintain_test.run_hello!
        active_maintain_test.run_hello?.should be_true
        active_maintain_test.should_not_receive(:hello!)
        active_maintain_test.status = :foo
        active_maintain_test.save
      end

      it "should run the :bar exit hook if run_hello? returns false" do
        active_maintain_test = ActiveMaintainTest.create(:status => :bar)
        active_maintain_test.run_hello?.should be_false
        active_maintain_test.should_receive(:hello!)
        active_maintain_test.status = :foo
        active_maintain_test.save
      end

      it "should ONLY run the :bar / :show_my_id exit hook AFTER the record is saved" do
        active_maintain_test = ActiveMaintainTest.new(:status => :foo)
        active_maintain_test.status = :bar
        active_maintain_test.should_receive(:puts).with(1)
        active_maintain_test.save!
      end
    end

    describe "named_scopes" do
      before :all do
        ActiveMaintainTest.maintain :status do
          state :new, :default => true
          state :old
          state :foo
          state :bar
          aggregate :everything, :as => [:new, :old, :foo, :bar]
          aggregate :fakes, :as => [:foo, :bar]
        end
      end

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

    describe "serialization" do
      before :all do
        ActiveMaintainTest.maintain :status do
          state :new, :default => true
          state :old
          state :foo
          state :bar
          aggregate :everything, :as => [:new, :old, :foo, :bar]
          aggregate :fakes, :as => [:foo, :bar]
        end
      end

      it "should not screw with to_json" do
        foo = ActiveMaintainTest.create
        json_hash = {:active_maintain_test => {:id => foo.id, :permissions => 0, :status => :new}.stringify_keys}.stringify_keys
        foo.as_json.should == json_hash
        json_hash.to_json.should == json_hash.to_json
      end
    end
  end
end
