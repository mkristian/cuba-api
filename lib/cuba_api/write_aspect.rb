# -*- Coding: utf-8 -*-

module CubaApi
  module WriteAspect

    module ClassMethods
      def append_aspect( arg )
        aspects << arg
        warn "[CubaAPI] Appended aspect #{arg}"
      end

      def prepend_aspect( arg )
        aspects.insert( 0, arg )
        warn "[CubaAPI] Prepended aspect #{arg}"
      end

      def aspects
        self[ :aspects ] ||= []
      end
    end

    def head( status )
      res.status = status
      res.write ''
    end

    def write( obj, options = {} )
      self.res.status = options[:status] || 200
      # make sure we inherit aspects and repsect the order
      aspects = self.class[ :aspects ] # == CubaAPI ? [] : self.class.superclass[ :aspects ]
      (aspects + self.class[ :aspects ]).uniq.each do |w|
        obj = send( w, obj, options ) if obj
      end
      res.write obj.to_s
    end
  end
end
