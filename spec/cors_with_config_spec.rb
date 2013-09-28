require File.expand_path( File.join( File.dirname( __FILE__ ),
                                     'spec_helper.rb' ) )
require 'cuba_api/config'
require 'cuba_api/cors'

describe CubaApi::Cors do

  before do
    Cuba.reset!
    class ACuba < Cuba
      plugin CubaApi::Config
      plugin CubaApi::Cors
      cors_setup do |cors|
        cors.max_age = 123
        cors.methods = :put
        cors.headers = 'x-requested-with'
        cors.origins = 'middleearth'
        cors.expose = 'x-requested-with'
      end
      define do

        on_cors do
          on put do
            res.write "put answered"
          end
          
          on do
            res.status = 404
          end
        end
        
      end
    end
  end

  let( :env ) do
    { 'REQUEST_METHOD' => 'OPTIONS',
      'PATH_INFO' => '/account',
      'HTTP_ORIGIN' => 'http://middleearth',
      'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => 'PUT',
      'HTTP_ACCESS_CONTROL_REQUEST_HEADERS' => 'x-requested-with'
    }
  end

  it 'should response OK' do
    _, headers, _ = ACuba.call( env )

    headers[ "Access-Control-Max-Age" ].must.eq "123"
    headers[ "Access-Control-Allow-Origin" ].must.eq "http://middleearth"
    headers[ "Access-Control-Allow-Methods" ].must.eq "PUT"
    headers[ "Access-Control-Allow-Headers" ].must.eq 'X-REQUESTED-WITH'
    headers[ "Access-Control-Expose-Headers" ].must.eq 'x-requested-with'

    env[ 'REQUEST_METHOD' ] = 'PUT'
    _, _, resp = ACuba.call( env )
    resp.join.must.eq 'put answered'
  end

  it 'should response FAILED' do
    env[ 'HTTP_ORIGIN' ] = 'http://localhost'
    env[ 'HTTP_ACCESS_CONTROL_REQUEST_METHOD' ] = 'POST'
    env[ 'HTTP_ACCESS_CONTROL_REQUEST_HEADERS' ] = 'x-timeout'

    _, headers, _ = ACuba.call( env )

    headers[ "Access-Control-Max-Age" ].must.eq "123"
    headers[ "Access-Control-Allow-Origin" ].must.eq nil
    headers[ "Access-Control-Allow-Methods" ].must.eq nil
    headers[ "Access-Control-Allow-Headers" ].must.eq nil
    headers[ "Access-Control-Expose-Headers" ].must.eq 'x-requested-with'

    env[ 'REQUEST_METHOD' ] = 'PUT'
    status, _, _ = ACuba.call( env )
    status.must.eq 404
  end

end
