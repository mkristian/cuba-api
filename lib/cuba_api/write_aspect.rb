#
# Copyright (C) 2012 Christian Meier
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
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