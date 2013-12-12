module CubaApi
  module ResponseStatus
    def response_status( obj, options = {})
      if options[:response_status] != false
        if obj.respond_to?( :errors ) && obj.errors.size > 0
          res.status = 412 # Precondition Failed
          obj = obj.errors
          if obj.respond_to? :to_hash
            status_logger.info { obj.to_hash.values.join( "\n" ) }
          else
            status_logger.info { obj.inspect }
          end
        elsif req.post?
          res.status = 201 # Created
          if obj.respond_to?( :id ) && ! res[ 'Location' ]
            res[ 'Location' ] = env[ 'SCRIPT_NAME' ].to_s + "/#{obj.id}"
          end
        elsif req.delete?
          res.status = 204 # No Content
          obj = ''
        end
      end
      obj
    end

    def self.included( base )
      base.prepend_aspect :response_status
    end

    private

    def status_logger
      logger_factory.logger( "CubaApi::ResponseStatus" )
    end
  end
end
