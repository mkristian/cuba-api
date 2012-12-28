# -*- Coding: utf-8 -*-
module CubaApi
  module AcceptContent

    module ClassMethods

      MIMES = { :yaml => ['application/x-yaml', 'text/yaml'],
        :json => ['application/json'],
        :xml => ['application/xml'] }

      def accept( *args )
        args.each do |arg|
          (MIMES[ arg ] || []).each do |mime|
            mimes[ mime ] = "to_#{arg}".to_sym
          end
        end
        warn "[CubaAPI] Accept: #{mimes.keys.join(', ')}"
      end

      def mimes
        self[ :mimes ] ||= {}
      end
    end

    def accept_content( obj, options = {} )
      script = env[ 'SCRIPT_NAME' ]
      if script =~ /\./
        extension = script.sub( /^.*\./, '' )
        mime = ClassMethods::MIMES[ extension.to_sym ] || []
        _accept( obj, mime.first )
      else
        _accept( obj, env[ 'HTTP_ACCEPT' ] )
      end
    end

    def _accept( obj, mime )
      if self.class.mimes.key?( mime )
        res[ "Content-Type" ] = mime + "; charset=utf-8"
        obj.send self.class[ :mimes ][ mime ]
      else
        head 404
        nil
      end
    end
    private :_accept

    def self.included( base )
      base.append_aspect :accept_content
    end
  end
end
