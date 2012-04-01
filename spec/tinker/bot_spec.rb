require File.expand_path(File.dirname(__FILE__) + '/../../lib/tinker.rb')

describe Tinker::Bot do
  it "should allow a new bot to be created" do
    Tinker::Bot.new.instance_of?(Tinker::Bot).should be_true
  end
  
  it "should allow a real name to be set" do
    t = Tinker::Bot.new(:real_name => 'Test Bot')
    t.real_name.should == 'Test Bot'
    t.real_name = 'Test 2'
    t.real_name.should == 'Test 2'
  end
  
  it "should connect to an IRC network" do
    t = Tinker::Bot.new
    t.new_connection(
      :server => 'irc.test.com',
      :port => 6667,
      :nick => 'test'
    ).is_a?(Tinker::Connection).should be_true
  end
end