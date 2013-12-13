# single spec setup
$LOAD_PATH.unshift File.join( File.dirname( File.expand_path( File.dirname( __FILE__ ) ) ),
                              'lib' )

p $LOAD_PATH
gem 'minitest'
require 'minitest/autorun'

require 'cuba'
ENV["MT_NO_EXPECTATIONS"] = "true"

require 'mustard'

module Mustard
  class Failure < MiniTest::Assertion
    def initialize( *args )
      super
      begin
        raise
      rescue => e
        @result = e.backtrace.detect { |l| nil == ( l =~ /lib\/mustard/ || l =~ /spec\/spec_helper.rb/ ) }
      end
    end
    
    def backtrace
      [@result]
    end
  end
end
