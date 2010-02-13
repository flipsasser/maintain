describe 'Maintain' do
  it "should not monkey patch Object" do
    lambda {
      require "lib/maintain"
    }.should_not change(Object, :methods)
  end
end