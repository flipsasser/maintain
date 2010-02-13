# Some specs to check against ActiveRecord conflicts. Rails tends to blow
# shit up when you build it outside of Rails. We'll see how this goes...

require 'lib/maintain'

proceed = false
begin
  require 'rubygems'
  require 'active_record'
  proceed = true
rescue LoadError
  puts 'Not testing ActiveRecord (unavailable)'
end

if proceed
  ActiveRecord::Base.establish_connection({:adapter => 'sqlite3', :database => ':memory:', :pool => 5, :timeout => 5000})
  class ActiveMaintainTest < ActiveRecord::Base; include Maintain; end

  describe ActiveRecord::Base do
    after :all do
      Object.class_eval do
        remove_const(:ActiveRecord)
      end
    end

    describe "with a string state column" do
      before :each do
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
    end
  end
end