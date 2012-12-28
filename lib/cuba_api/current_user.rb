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
        session['user'] =  self.class.sessions.to_session( user )
        @_current_user = user
      else
        @_current_user ||= self.class.sessions.from_session( session['user'] )
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
