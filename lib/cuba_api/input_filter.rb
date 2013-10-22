require 'ixtlan/babel/factory'
require 'multi_json'
module CubaApi
  module InputFilter

    module ClassMethods
      def factory
        @_factory ||= Ixtlan::Babel::Factory.new
      end
    end

    def req_filter( model = nil, context = nil )
      @_filter ||=
        begin
          filter = self.class.factory.new_filter( model ).use( context )
          filter.filter_it( parse_request_body )
        end
    end

    protected

    def parse_request_body
      if env[ 'CONTENT_TYPE' ] =~ /^application\/json/
        body = req.body.read
        body.empty? ? {} : MultiJson.load( body )
      else
        {}
      end
    end
  end
end
