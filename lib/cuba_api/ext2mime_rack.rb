module CubaApi
  class Ext2MimeRack
    def initialize( app, *allowed)
      @app = app
      @allowed = allowed
    end
  
    def call(env)
      ext = env[ 'PATH_INFO' ].sub( /.*\./, '' )
      if ext && @allowed.member?( ext )
        mime = Rack::Mime.mime_type( '.' + ext )
        env[ 'PATH_INFO_ORIG' ] = env[ 'PATH_INFO' ].dup
        env[ 'HTTP_ACCEPT' ] = mime
        env[ 'PATH_INFO' ].sub!( /\..*/, '' )
      end
      status, headers, body = @app.call(env)
    end
  end
end
