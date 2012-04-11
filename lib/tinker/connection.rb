require 'socket'

class Tinker
  class Connection
    attr_accessor :server
    attr_accessor :port
    attr_accessor :nick
    attr_accessor :real_name
    attr_accessor :channels
    attr_reader :socket

    def initialize(opts)
      raise Tinker::Connection::InvalidConnection unless (opts[:server] && opts[:nick])
      opts[:port] = 6667 unless opts[:port]
      opts.each do |k,v|
        self.send(:"#{k.to_s}=", v) if self.respond_to?(:"#{k.to_s}=")
      end
      @real_name = @nick if @real_name.nil? or @real_name.empty?
    end

    def connect
      @socket ||= TCPSocket.open(@server, @port)
      @socket.puts "NICK #{@nick}"
      @socket.puts "USER #{@nick} 0 * : #{@real_name}"
      listen
    end

    def join(channel)
      raise Tinker::Connection::NotConnectedToNetwork unless @socket and @socket.is_a? TCPSocket
      @socket.puts "JOIN #{channel}"
    end

    def listen
      raise Tinker::Connection::NotConnectedToNetwork unless @socket and @socket.is_a? TCPSocket
      until @socket.eof? do
        message = @socket.gets
        if (pong = /^PING (.*)$/.match(message))
          @socket.puts "PONG #{pong[1]}"
        end
      end
    end

    class InvalidConnection < Exception
      def message
        "You must provide both a server and nick to create a valid connection"
      end
    end

    class NotConnectedToNetwork < Exception
      def message
        "You are not connected to the network. Establish a connection by calling Tinker::Connection#connect"
      end
    end

  end
end