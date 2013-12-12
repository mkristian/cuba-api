module CubaApi
  module Rack
    class AllowSessionRack
      def initialize( app, *not_pattern )
        @app = app
        @regexp = /^\/#{not_pattern.join( '|^\/' )}/
      end
      
      def call( env )
        status, headers, resp = @app.call( env )
        if not( env[ 'PATH_INFO' ].match @regexp )
          headers.delete( 'Set-Cookie' )
        end
        [ status, headers, resp ]
      end
    end
  end
end
