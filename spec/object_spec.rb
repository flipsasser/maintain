require 'spec_helper'

describe 'Maintain' do

  it "does not monkey patch Object" do
    expect(lambda {
      require 'maintain'
    }).not_to change(Object, :methods)
  end

end
