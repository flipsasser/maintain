proceed = false
begin
  require 'rubygems'
  gem 'datamapper'
  require 'datamapper'
  proceed = true
rescue Gem::LoadError, LoadError
  puts 'Not testing DataMapper (unavailable)'
end

if proceed
  # Use load to have it evaluate the DataMapper extension logic again, in the event
  # that we've already done that with a previous test.
  load 'lib/maintain.rb'

  DataMapper.setup(:default, "sqlite3::memory:")

  class ::DataMapperMaintainTest
    include DataMapper::Resource
    extend Maintain

    property :id, Serial
    property :status, String

    maintain :status do
      state :new, :default => true
      state :old
      state :foo
      state :bar
      aggregate :everything, :as => [:new, :old, :foo, :bar]
      aggregate :fakes, :as => [:foo, :bar]
    end
  end

  DataMapper.auto_upgrade!

  describe Maintain, "Datamapper::Resource" do
    it "should automatically be extended" do
      DataMapper::Resource.instance_methods.should include('maintain')
    end

    describe "accessors" do
      it "should default to 'new'" do
        DataMapperMaintainTest.new.status.should == 'new'
        DataMapperMaintainTest.new.status.should == :new
      end

      it "should allow us to update its status to 'old'" do
        active_maintain_test = DataMapperMaintainTest.new(:status => 'old')
        active_maintain_test.status.should == 'old'
        lambda {
          active_maintain_test.save!
        }.should_not raise_error
        DataMapperMaintainTest.first.status.should == 'old'
      end

      it "should return the correct name when told to" do
        active_maintain_test = DataMapperMaintainTest.create(:status => 'old')
        DataMapperMaintainTest.first.status.name.should == 'old'
      end
    end

    describe "named_scopes" do
      it "should create named_scopes for all states" do
        DataMapperMaintainTest.should respond_to(:old)
        DataMapperMaintainTest.old.should respond_to(:each)
      end

      it "should create named_scopes for all aggregates" do
        DataMapperMaintainTest.should respond_to(:everything)
        DataMapperMaintainTest.everything.should respond_to(:each)
      end

      it "should return the correct collections on aggregates" do
        DataMapperMaintainTest.all.destroy!
        one = DataMapperMaintainTest.create(:status => :foo)
        two = DataMapperMaintainTest.create(:status => :bar)
        three = DataMapperMaintainTest.create(:status => :new)
        four = DataMapperMaintainTest.create(:status => :old)
        DataMapperMaintainTest.fakes.should == [one, two]
        DataMapperMaintainTest.everything.should == [one, two, three, four]
      end

    end
  end
end