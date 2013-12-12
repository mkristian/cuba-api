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
  module AcceptContent

    module ClassMethods

      MIMES = { :yaml => ['application/x-yaml', 'text/yaml'],
        :json => ['application/json'],
        :xml => ['application/xml'] }

      def accept( *args )
        args.each do |arg|
          (MIMES[ arg ] || []).each do |mime|
            if arg == :yaml
              require 'safe_yaml' unless defined?( YAML )
            end
            mimes[ mime ] = "to_#{arg}".to_sym
          end
        end
        accept_logger.info { "Accept: #{mimes.keys.join(', ')}" }
      end

      def mimes
        self[ :mimes ] ||= {}
      end

      def accept_logger
        logger_factory.logger( "CubaApi::AcceptContent" )
      end
    end

    def accept_content( obj, options = {} )
      mime = env[ 'HTTP_ACCEPT' ]
      if self.class.mimes.key?( mime )
        res[ "Content-Type" ] = mime + "; charset=utf-8"
        obj.send self.class[ :mimes ][ mime ]
      else
        self.class.accept_logger.debug { "'#{mime}' not in allowed list #{self.class[ :mimes ].keys.inspect}" }
        no_body :not_found
        nil
      end
    end

    def self.included( base )
      base.append_aspect :accept_content
    end
  end
end
