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
  module CurrentUser

    module ClassMethods

      def sessions
        self[ :sessions ]
      end

    end

    def current_user( user = nil )
      if user
        session[ 'user' ] =  self.class.sessions.to_session( user )
        @_current_user = user
      elsif env[ 'rack.session' ]
        @_current_user ||= self.class.sessions.from_session( session[ 'user' ] )
      end
    end

    def reset_current_user
      session[ 'user' ] = nil
    end

    def authenticated?
      current_user != nil
    end

    def current_user_name
      authenticated? ? current_user.login : "???"
    end
  end
end
