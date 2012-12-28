# -*- Coding: utf-8 -*-
require "cuba"

module CubaApi
  module Config
    module ClassMethods

      def config
        @config ||= {}
      end

      def []( key )
        config[ key ] || settings[ key ] || (superclass.respond_to?( :[] ) ? superclass[ key ] : (superclass == Cuba ? Cuba.settings[ key ] : nil ) )
      end

      def []=( key, value )
        config[ key ] = value
      end
    end
  end
end
