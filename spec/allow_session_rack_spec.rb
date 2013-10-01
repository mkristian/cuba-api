require 'spec_helper'
require 'cuba_api/allow_session_rack'

describe CubaApi::AllowSessionRack do

  before do
    Cuba.reset!
    Cuba.use CubaApi::AllowSessionRack, 'session', 'system'
    Cuba.use Rack::Session::Cookie, :secret => 'secret'
    Cuba.define do
      on 'session' do
        session[ 'name' ] = :me
      end
    end
  end

  it 'allows session' do
     _, headers, _ = Cuba.call( { 'PATH_INFO' => '/session',
                                  'SCRIPT_NAME' => '/session' } )

    headers[ 'Set-Cookie' ].must_not.eq nil
  end

  it 'does NOT allows session' do
     _, headers, _ = Cuba.call( { 'PATH_INFO' => '/something',
                                  'SCRIPT_NAME' => '/something' } )

    headers[ 'Set-Cookie' ].must.eq nil
  end
end
