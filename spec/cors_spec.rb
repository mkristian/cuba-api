require File.expand_path( File.join( File.dirname( __FILE__ ),
                                     'spec_helper.rb' ) )
require 'cuba_api/config'
require 'cuba_api/cors'

describe CubaApi::Cors do

  before do
    Cuba.reset!
    Cuba.plugin CubaApi::Config
    Cuba.plugin CubaApi::Cors
    Cuba.define do

      on_cors 'path/to/:who' do |who|
        on post do
          res.write "post from #{who}"
        end
      end

      on_cors_method [:post, :get], 'office/:me' do |me|
        on post do
          res.write "#{me} posted"
        end
      end

      on_cors_method :delete, 'something' do
        res.write "delete something"
      end

      on_cors_method :delete, 'home/:me' do |me|
        res.write "delete #{me}"
      end

      on_cors do
        on put do
          res.write "put answered"
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

  it 'should response with catch section' do
    _, headers, _ = Cuba.call( env )

    headers[ "Access-Control-Max-Age" ].must.eq "86400"
    headers[ "Access-Control-Allow-Origin" ].must.eq "http://middleearth"
    headers[ "Access-Control-Allow-Methods" ].must.eq "GET, HEAD, POST, PUT, DELETE"
    headers[ "Access-Control-Allow-Headers" ].must.eq 'x-requested-with'
    headers[ "Access-Control-Allow-Expose-Headers" ].must.eq nil

    env[ 'REQUEST_METHOD' ] = 'PUT'
    _, _, resp = Cuba.call( env )
    resp.join.must.eq 'put answered'
  end

  it 'should with path/to/:me section' do
    env[ 'PATH_INFO' ] = '/path/to/alf'
    env[ 'SCRIPT_NAME' ] = '/path/to/alf'

    _, headers, _ = Cuba.call( env )

    headers[ "Access-Control-Max-Age" ].must.eq "86400"
    headers[ "Access-Control-Allow-Origin" ].must.eq "http://middleearth"
    headers[ "Access-Control-Allow-Methods" ].must.eq "GET, HEAD, POST, PUT, DELETE"
    headers[ "Access-Control-Allow-Headers" ].must.eq 'x-requested-with'
    headers[ "Access-Control-Allow-Expose-Headers" ].must.eq nil

    env[ 'REQUEST_METHOD' ] = 'POST'
    _, _, resp = Cuba.call( env )
    resp.join.must.eq 'post from alf'
  end

  it 'should with home/:me section' do
    env[ 'PATH_INFO' ] = '/home/gandalf'
    env[ 'SCRIPT_NAME' ] = '/home/gandalf'
    env[ 'HTTP_ACCESS_CONTROL_REQUEST_METHOD' ] = 'DELETE'

    _, headers, _ = Cuba.call( env )

    headers[ "Access-Control-Max-Age" ].must.eq "86400"
    headers[ "Access-Control-Allow-Origin" ].must.eq "http://middleearth"
    headers[ "Access-Control-Allow-Methods" ].must.eq "DELETE"
    headers[ "Access-Control-Allow-Headers" ].must.eq 'x-requested-with'
    headers[ "Access-Control-Allow-Expose-Headers" ].must.eq nil

    env[ 'REQUEST_METHOD' ] = 'DELETE'
    _, _, resp = Cuba.call( env )
    resp.join.must.eq 'delete gandalf'
  end

  it 'should with office/:me section' do
    env[ 'PATH_INFO' ] = '/office/frodo'
    env[ 'SCRIPT_NAME' ] = '/home/frodo'
    env[ 'HTTP_ACCESS_CONTROL_REQUEST_METHOD' ] = 'POST'

    _, headers, _ = Cuba.call( env )

    headers[ "Access-Control-Max-Age" ].must.eq "86400"
    headers[ "Access-Control-Allow-Origin" ].must.eq "http://middleearth"
    headers[ "Access-Control-Allow-Methods" ].must.eq "POST, GET"
    headers[ "Access-Control-Allow-Headers" ].must.eq 'x-requested-with'
    headers[ "Access-Control-Allow-Expose-Headers" ].must.eq nil

    env[ 'REQUEST_METHOD' ] = 'POST'
    _, _, resp = Cuba.call( env )
    resp.join.must.eq 'frodo posted'
  end
end
