require File.expand_path(File.dirname(__FILE__) + '/../../lib/tinker.rb')

describe Tinker::Connection do
  before :each do
    @server = 'irc.lol.com'
    @nick = 'hi'
    @real_name = 'hello'

    @sock = mock('socket')
    TCPSocket.stub(:open){ @sock }
    @sock.stub(:is_a?){|x| x == TCPSocket ? true : false }
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
  
  describe "connect" do
    it "should connect to a given irc network and listen for messages from the server" do
      c = Tinker::Connection.new(:server => @server, :nick => @nick)
      TCPSocket.should_receive(:open).with(c.server, c.port).and_return(@sock)
      @sock.should_receive(:puts).at_least(2).times
      c.should_receive(:listen)
      c.connect
    end

    it "should set real name and nick upon connecting" do
      c = Tinker::Connection.new(:server => @server, :nick => @nick, :real_name => @real_name)
      @sock.should_receive(:puts).with("NICK #{@nick}")
      @sock.should_receive(:puts).with("USER #{@nick} 0 * : #{@real_name}")
      c.should_receive(:listen)
      c.connect
    end

    it "should set real name to the nick as a default" do
      c = Tinker::Connection.new(:server => @server, :nick => @nick)
      @sock.should_receive(:puts).with("NICK #{@nick}")
      @sock.should_receive(:puts).with("USER #{@nick} 0 * : #{@nick}")
      c.should_receive(:listen)
      c.connect
    end
  end

  describe "join" do
    it "should join a channel" do
      c = Tinker::Connection.new(:server => @server, :nick => @nick)
      @sock.should_receive(:puts).at_least(2).times
      c.should_receive(:listen)
      c.connect
      @sock.should_receive(:puts).with("JOIN #test_channel")
      c.join("#test_channel")
    end

    it "should fail joining a channel if it's not connected to a network" do
      c = Tinker::Connection.new(:server => @server, :nick => @nick)
      e_thrown = false
      begin
        c.join('#test')
      rescue Exception => e
        e.is_a?(Tinker::Connection::NotConnectedToNetwork).should be_true
        e_thrown = true
      end
      e_thrown.should be_true
    end
  end

  describe "listen" do
    before :each do
      @c = Tinker::Connection.new(:server => @server, :nick => @nick)
    end

    it "should fail listening if it's not connected to a network" do
      e_thrown = false
      begin
        @c.send(:listen)
      rescue Exception => e
        e.is_a?(Tinker::Connection::NotConnectedToNetwork).should be_true
        e_thrown = true
      end
      e_thrown.should be_true
    end

    describe "(when connected)" do
      before :each do
        @sock.should_receive(:puts).at_least(2).times
        @sock.should_receive(:eof?).and_return(false, true)
        @c.stub(:listen)
        @c.connect
        @c.unstub(:listen)
      end

      it "should look for PINGs and respond with appropriate PONGs" do
        @sock.should_receive(:gets).and_return("PING abc123.lol.irc")
        @sock.should_receive(:puts).with("PONG abc123.lol.irc")
        @c.listen
      end
    end
  end

end