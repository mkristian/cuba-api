module CubaApi
  module Utils
   
    # matcher
    def no_path
      Proc.new { env[ 'PATH_INFO' ].empty? }
    end

    # matcher
    def option
      req.options?
    end

    def to_float( name, default = nil )
     v = req[ name ]
     if v
       v.to_f
     else
       default
     end
    end

    def to_int( name, default = nil )
      v = req[ name ]
      if v
        v.to_i
      else
        default
      end
    end

    def to_boolean( name, default = nil )
      v = req[ name ]
      if v
        v == 'true'
      else
        default
      end
    end

    def offset_n_limit( method, set )
      count = set.count
      offset = to_int( 'offset' ).to_i
      limit = ( to_int( 'count' ) || count ) - 1 + offset
      { method => set[ offset..limit ], :offset => offset, :total_count => count }
    end
    
    def last_modified( last )
      res[ 'Last-Modified' ] = rfc2616( last ) if last
    end

    def modified_since
      @modified_since ||=
        if date = env[ 'HTTP_IF_MODIFIED_SINCE' ]
          DateTime.parse( date )
        end
    end

    def expires_in( minutes )
      now = DateTime.now
      res[ 'Date' ] = rfc2616( now )
      res[ 'Expires' ] = rfc2616( now + minutes / 1440.0 )
    end

    def browser_only_cache
      res[ 'Date' ] = rfc2616
      res[ 'Expires' ] = "Fri, 01 Jan 1990 00:00:00 GMT"
      res[ 'Cache-Control' ] = "private, max-age=0, must-revalidate"
    end

    def browser_only_cache_no_store
      browser_only_cache
      res[ 'Cache-Control' ] += ", no-store"
    end

    def no_cache_no_store
      no_cache
      res["Cache-Control"] += ", no-store"
    end

    def no_cache
      res["Date"] = rfc2616
      res["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
      res["Pragma"] = "no-cache"
      res["Cache-Control"] = "no-cache, must-revalidate"
    end

    def content_type( mime )
      res[ 'Content-Type' ] = mime if mime
    end

    def rfc2616( time = DateTime.now )
      time.to_time.utc.rfc2822.sub( /.....$/, 'GMT')
    end
  end
end
