require File.expand_path(File.dirname(__FILE__) + '/../../lib/tinker.rb')

describe Tinker::Connection do
  before :each do
    @server = 'irc.lol.com'
    @nick = 'hi'
    @real_name = 'hello'
  end
  
  it "should fail initialization if server or nick info is missing" do
    begin
      c = Tinker::Connection.new({})
    rescue Exception => e
      e.is_a?(Tinker::Connection::InvalidConnection).should be_true
    end
    begin
      c = Tinker::Connection.new(:nick => @nick)
    rescue Exception => e
      e.is_a?(Tinker::Connection::InvalidConnection).should be_true
    end
    begin
      c = Tinker::Connection.new(:server => @server)
    rescue Exception => e
      e.is_a?(Tinker::Connection::InvalidConnection).should be_true
    end
  end
  
  it "should use port 6667 by default unless a different port is given" do
    c = Tinker::Connection.new(:server => @server, :nick => @nick)
    c.port.should == 6667
    c = Tinker::Connection.new(:server => @server, :nick => @nick, :port => 6668)
    c.port.should == 6668
  end
  
  it "should connect to a given irc network" do
    c = Tinker::Connection.new(:server => @server, :nick => @nick)
    sock = mock('socket')
    TCPSocket.should_receive(:open).with(c.server, c.port).and_return(sock)
    sock.should_receive(:puts).at_least(2).times
    c.connect
  end

  it "should set real name and nick upon connecting" do
    c = Tinker::Connection.new(:server => @server, :nick => @nick, :real_name => @real_name)
    sock = mock('socket')
    TCPSocket.should_receive(:open).and_return(sock)
    sock.should_receive(:puts).with("NICK #{@nick}")
    sock.should_receive(:puts).with("USER #{@nick} 0 * : #{@real_name}")
    c.connect
  end

  it "should set real name to the nick as a default" do
    c = Tinker::Connection.new(:server => @server, :nick => @nick)
    sock = mock('socket')
    TCPSocket.should_receive(:open).and_return(sock)
    sock.should_receive(:puts).with("NICK #{@nick}")
    sock.should_receive(:puts).with("USER #{@nick} 0 * : #{@nick}")
    c.connect
  end

  it "should fail joining a channel if it's not connected to a network" do
    c = Tinker::Connection.new(:server => @server, :nick => @nick)
    sock = mock('socket')
    begin
      c.join('#test')
    rescue Exception => e
      e.is_a?(Tinker::Connection::NotConnectedToNetwork).should be_true
    end
  end

end