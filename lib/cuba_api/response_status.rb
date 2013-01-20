module CubaApi
  module ResponseStatus
    def response_status( obj, options = {})
      if options[:response_status] != false
        if obj.respond_to?( :errors ) && obj.errors.size > 0
          res.status = 412 # Precondition Failed
          obj = obj.errors
        elsif req.post?
          res.status = 201 # Created
          if obj.respond_to? :id
            res[ 'Location' ] = env[ 'SCRIPT_NAME' ] + "/#{obj.id}"
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
  end
end
