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

require 'ixtlan/user_management/guard'

# TODO move to upstream
class Ixtlan::UserManagement::Permission
  attribute :parent, Ixtlan::UserManagement::Permission
end

module CubaApi
  module Guard
    module ClassMethods

      def guard( &block )
        self[ :guard ] ||= block ||
          begin
            warn 'no guard configured. default guard denies eveythings !'
            guard = Ixtlan::UserManagement::Guard.new
            Proc.new do |groups|
              guard
            end
          end
      end
      
    end

    def current_groups
      current_user.groups
    end

    def allowed_associations
      guard.associations( guard_context, @_method )
    end

    def on_context( name, &block )
      perm = guard.permissions( name )
      if perm && perm.parent &&
          perm.parent.resource !=  guard_context
        raise 'parent resource is not guarded'
      end
      on name do
        old = guard_context
        guard_context( name )
        yield( *captures )
        guard_context( old )
      end
    end

    def on_association
      on :association do |association|
        # TODO one method in guard
        asso = guard.permissions( guard_context ).associations
        if asso.empty? or asso.include?( association )
          yield( association )
        else
          no_body :forbidden 
        end
      end
    end
    
    def on_guard( method, *args)
      args.insert( 0, send( method ) )
      on *args do
        
        @_method = method
        
        warn "[CubaApi::Guard] check #{method.to_s.upcase} #{guard_context}: #{guard.allow?( guard_context, method )}"
        # TODO guard needs no association here
        if guard.allow?( guard_context, method, (allowed_associations || []).first )
          
          yield( *captures )
        else
          no_body :forbidden # 403
        end
      end
    end

    private

    def guard_context( ctx = nil )
      if ctx
        @_conetxt = (req.env[ 'guard_context' ] = ctx)
      else
        @_context ||= req.env[ 'guard_context' ]
      end
    end

    def guard
      self.class.guard.call( current_groups )
    end

  end
end
