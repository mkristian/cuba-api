module CubaApi
  class NoSessionRack
    def initialize( app, *not_pattern )
      @app = app
      @reg_exp = /^\/#{not_pattern.join( ',^\/' )}/
    end
    
    def call( env )
      status, headers, resp = @app.call( env )
      if not( env[ 'PATH_INFO' ] =~ @regexp )
        headers.delete( 'Set-Cookie' )
      end
      [ status, headers, resp ]
    end
  end
end
