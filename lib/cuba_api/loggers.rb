module CubaApi
  
  module Loggers
    module ClassMethods

      def logger_factory
        self[ :loggers ] ||=  CubaApi::LoggerFactory.new
      end

    end

    def logger_factory
      self.class.logger_factory
    end
  end

  class LoggerFactory

    def self.level=( level )
      @level = level
    end

    def self.logger( cat )
      loggers[ cat ] ||= Logger.new( cat, @level )
    end

    def logger( cat )
      self.class.logger( cat )
    end

    private

    def self.loggers
      @loggers ||= {}
    end
  end

  class Logger

    private

    def do_puts( level, &block )
      if level >= @level
        puts( "[#{@cat}] #{block.call}" )
      end
    end

    def do_warn( level, &block )
      if level >= @level
        puts( "[#{@cat}] #{block.call}" )
      end
    end

    public

    def initialize( cat = 'ROOT', level = 1 )
      @level = ( level || 1 ).to_i
      @cat = cat
    end

    def debug( &block )
      do_puts( 0, &block )
    end
 
    def info( &block )
      do_puts( 1, &block )
    end
 
    def warn( &block )
      do_warn( 2, &block )
    end

    def error( &block )
      do_warn( 3, &block )
    end
  end
end
