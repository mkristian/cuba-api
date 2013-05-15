require 'ixtlan/babel/factory'
require 'multi_json'
module CubaApi
  module InputFilter

    module ClassMethods
      def factory
        @_factory ||= Ixtlan::Babel::Factory.new
      end
    end

    def new_instance( clazz, context = nil )
      clazz.new( params( clazz, context ) )
    end
    
    def params( clazz = nil, context = nil )
      filter_params_and_keeps( clazz, context )
      @_data[ 0 ] || {}
    end

    def keeps( clazz = nil, context = nil )
      filter_params_and_keeps( clazz, context )
      @_data[ 1 ] || {}
    end

    def filter_params_and_keeps( clazz, context )
      if clazz
        @_data ||= 
          begin
            filter = self.class.factory.new_filter( clazz ).use( context )
            filter.filter_it( parse_request_body )
          end
      end
      @_data ||= {}
    end
    private :filter_params_and_keeps

    def parse_request_body
      if env[ 'CONTENT_TYPE' ] =~ /^application\/json/
        MultiJson.load( req.body.read )
      else
        {}
      end
    end
    protected :parse_request_body
  end
end
