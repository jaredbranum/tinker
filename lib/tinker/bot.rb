class Tinker
  class Bot
    attr_accessor :real_name

    def initialize(opts={})
      opts.each do |k,v|
        self.send(:"#{k.to_s}=", v) if self.respond_to?(:"#{k.to_s}=")
      end
      @connections = []
    end
    
    def new_connection(opts)
      conn = Tinker::Connection.new(opts)
      return false unless conn
      @connections << conn
      conn
    end

  end
end