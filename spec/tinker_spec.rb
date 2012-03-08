require File.expand_path(File.dirname(__FILE__) + '/../lib/tinker.rb')

describe Tinker do
  it "should allow a bot to be created with .new" do
    Tinker.new.instance_of?(Tinker).should be_true
  end
end