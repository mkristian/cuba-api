# -*- Coding: utf-8 -*-

module CubaApi
  module Guard
    def allowed?( *group_names )
      authenticated? && ( allowed_groups( *group_names ).size > 0 )
    end

    def allowed_groups( *group_names )
      current_groups.select { |g| group_names.member?( g.name ) }
    end

    def current_groups
      current_user.groups
    end
  end
end
