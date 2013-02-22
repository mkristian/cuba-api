module CubaApi
  module Utils
   
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

    def offset_n_limit( method, set )
      count = set.count
      offset = to_int( 'offset' ).to_i
      limit = ( to_int( 'count' ) || count ) - 1 + offset
      { method => set[ offset..limit ], :offset => offset, :total_count => count }
    end
    
    def last_modified( last )
      res[ 'Last-Modified' ] = last.rfc2822
    end

    def modified_since
      @modified_since ||=
        if date = env[ 'HTTP_IF_MODIFIED_SINCE' ]
          DateTime.parse( date )
        end
    end

    def expires_in( minutes )
      now = DateTime.now
      res[ 'Expires' ] = ( now + minutes / 1440.0 ).rfc2822
    end

    def content_type( mime )
      res[ 'Content-Type' ] = mime if mime
    end
  end
end
