require 'spec_helper'

describe 'Maintain' do
  it "should not monkey patch Object" do
    lambda {
      require 'maintain'
    }.should_not change(Object, :methods)
  end
end