class CORS

  DEFAULT_METHODS = [ 'GET',  'HEAD', 'POST', 'PUT', 'DELETE' ]

  def initialize( options, &block )
    @options = options
    # only for inspect
    @config = options.config
    # set default max_ago
    self.max_age = 60 * 60 * 24 # one day
    block.call self if block
  end

  def config
    @config
  end

  def method_missing( method, *args )
    m = method.to_s
    if m.match /^_/
      if m =~ /=$/
        @options[ "cors_#{m[1..-2]}".to_sym ] = args.flatten
      else
        @options[ "cors_#{m[1..-1]}".to_sym ]
      end
    else
      super
    end
  end

  def max_age=( max )
    @options[ :cors_max_age ] = max
  end
  
  def expose=( expose )
    self._expose = expose
  end

  def origins=( *origins )
    self._origins = [ origins ].flatten
  end
  
  def origins( domain )
    origins = self._origins
    if origins == [ '*' ] || origins.nil? || origins.member?( domain )
      domain
    end
  end

  def methods=( *methods )
    self._methods = [ methods ].flatten.collect{ |h| h.to_s.upcase } 
  end
  
  def methods( method, methods = nil )
    methods = methods.collect { |m| m.to_s.upcase } if methods
    if (methods || self._methods || DEFAULT_METHODS).member?( method.to_s.upcase )
      methods || self._methods || DEFAULT_METHODS
    end
  end

  def allowed?( methods )
    if methods
      methods = methods.collect { |m| m.to_s.upcase }
      ( ( self._methods || DEFAULT_METHODS ) & methods ).size > 0
    else
      true
    end
  end

  def headers=( *headers )
    self._headers = [ headers ].flatten.collect{ |h| h.to_s.upcase }
  end

  def headers( headers )
    # return headers as they come in when not configured
    headers = headers.split( /,\s+/ ) if headers
    if self._headers && headers
      given = headers.collect{ |h| h.to_s.upcase }
      # give back the allowed subset of the given headers
      result = given & self._headers
      result = nil if result.empty?
      result
    else
      headers
    end
  end

  def allow_origin( req, res )
    if orig = origins( req[ 'HTTP_ORIGIN' ] )
      res[ 'Access-Control-Allow-Origin' ] = orig
    end
  end

  def process( req, res, methods )
    allow_origin( req, res )
    res[ 'Access-Control-Max-Age' ] = _max_age.to_s if _max_age
    if m = methods( req[ 'HTTP_ACCESS_CONTROL_REQUEST_METHOD' ], methods )
      res[ 'Access-Control-Allow-Methods' ] = m.join( ', ' )
    end
    if h = headers( req[ 'HTTP_ACCESS_CONTROL_REQUEST_HEADERS' ] )
      res[ 'Access-Control-Allow-Headers' ] = h.join( ', ' )
    end
    unless _expose.nil? || _expose.empty?
      res[ 'Access-Control-Expose-Headers' ] = _expose.join( ', ' )
    end
    res.status = 200
  end
end

module CubaApi
  module Cors
    module ClassMethods

      def cors_setup( &block )
        self[ :cors ] = CORS.new( self, &block )
      end
      
    end

    # # setup cors for in request coming here
    # on_cors do
    #   on ...
    #     ...
    #   end
    # end

    # # all methods
    # on_cors( 'my_path' ) do 
    #   on get, 'something' do
    #     ...
    #   end
    # end

    # # only put method allowed
    # on_cors_method( :put, 'my_path/change_something' ) do 
    #   on ...
    #     ...
    #   end
    # end

    # # only put method allowed
    # on_cors_method( [:post, :put], 'my_path/new' ) do 
    #   on ...
    #     ...
    #   end
    # end

    def on_cors( *args )
      _on_cors( nil, *args ) do |*vars|
        yield( *vars )
      end
    end

    def on_cors_method( methods, *args )
      methods = [ methods ] unless methods.is_a? Array
      _on_cors( methods, *args ) do |*vars|
        yield( *vars )
      end
    end

    private

    def _on_cors( methods = nil, *args )
      cors = ( self.class[ :cors ] ||= CORS.new( self.class ) )

      if req.options? && cors.allowed?( methods )
        #  send the response on option headers
        on *args do
          cors.process( env, res, methods )
        end
      else
        unless methods.nil?
          allowed = methods.collect do |m|
            send m.to_sym
          end.detect
          args.insert( 0, allowed.first )
        end
        args.insert( 0, cors.origins( env[ 'HTTP_ORIGIN' ] ) != nil )
        on *args do |*vars|
          cors.allow_origin( env, res )
          yield( *vars )
        end
      end
    end
  end
end

