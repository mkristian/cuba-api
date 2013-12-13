module CubaApi
  module ResponseStatus
    def response_status( obj, options = {})
      if options[ :response_status ] == false
        obj
      else
        handle_status( obj )
      end
    end

    def self.included( base )
      base.prepend_aspect :response_status
    end

    private

    def handle_status( obj )
      if obj.respond_to?( :errors ) && obj.errors.size > 0
        res.status = 412 # Precondition Failed
        log_errors( obj.errors )
        obj.errors
      elsif req.post?
        res.status = 201 # Created
        set_location( obj )
        obj
      elsif req.delete?
        res.status = 204 # No Content
        ''
      else
        obj
      end
    end

    def set_location( obj )
      if obj.respond_to?( :id ) && ! res[ 'Location' ]
        res[ 'Location' ] = env[ 'SCRIPT_NAME' ].to_s + "/#{obj.id}"
      end
    end
    
    def log_errors( errors )
      status_logger.info do
        if errors.respond_to? :to_hash
          errors.to_hash.values.join( "\n" )
        else
          errors.inspect
        end
      end
    end

    def status_logger
      logger_factory.logger( "CubaApi::ResponseStatus" )
    end
  end
end
