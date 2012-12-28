# -*- Coding: utf-8 -*-
require 'ixtlan/babel/factory'

module CubaApi
  module Serializer

    module ClassMethods
      def serializer_factory
        @_factory ||= Ixtlan::Babel::Factory.new
      end
    end

    def serializer( obj, options = {})
      if options[:serializer] == false || obj.is_a?( String )
        obj
      else
        s = self.class.serializer_factory.new( obj )
        s.use( options[ :use ] ) if options[ :use ]
        s
      end
    end

    def self.included( base )
      base.append_aspect :serializer
    end
  end
end
