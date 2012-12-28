require 'spec_helper'
require 'cuba_api/current_user'

class SessionManager
  def to_session( user )
    @u ||= user
  end
  def from_session( data )
    u = @u.dup unless @u.nil?
    def u.login; self;end
    u
  end
end

describe CubaApi::CurrentUser do

  before do
    Cuba.reset!
    Cuba.plugin CubaApi::CurrentUser
    Cuba.use Rack::Session::Cookie
    Cuba[ :sessions ] = SessionManager.new
    Cuba.define do
      on authenticated? do
        res.write current_user
      end
      on default do
        name = current_user_name
        current_user "user1"
        res.write "logged in - #{name}"
      end
    end
  end

  it 'should authenticate' do
     _, _, resp = Cuba.call({})
    
    resp.join.must.eq "logged in - ???"

     _, _, resp = Cuba.call({})
    
    resp.join.must.eq "user1"
  end
end
