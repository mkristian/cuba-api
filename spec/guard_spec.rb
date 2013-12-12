require File.expand_path( File.join( File.dirname( __FILE__ ),
                                     'spec_helper.rb' ) )
require 'cuba_api/loggers'
require 'cuba_api/config'
require 'cuba_api/utils'
require 'cuba_api/guard'
require 'ixtlan/user_management/group_model'

describe CubaApi::Guard do

  let( :root ) { Ixtlan::UserManagement::Group.new( :name => 'root' ) }

  before do
    Cuba.reset!
    Cuba.plugin CubaApi::Config
    Cuba.plugin CubaApi::Loggers
    Cuba.plugin CubaApi::Utils
    Cuba.plugin CubaApi::Guard
    Cuba.define do
      
      def current_groups
        @groups ||= [ root ]
      end

      on_context 'admins' do
        res.write "admins"
      end

      on_context 'users' do

        on_context 'accounts' do
          on_guard :get do
            res.write "get accounts"
          end
        end

        on_association do |id|
          on_guard :post do
            res.write "post#{id}"
          end
          on_guard :get do
            res.write "get#{id}"
          end
          on_guard :put do
            res.write "put#{id}"
          end
          on_guard :delete do
            res.write "delete#{id}"
          end
        end

        on_guard :post do
          res.write "post"
        end
        on_guard :get do
          res.write "get#{allowed_associations.inspect.gsub( /nil/, '' )}"
        end
        on_guard :put do
          res.write "put"
        end
        on_guard :delete do
          res.write "delete"
        end
      end
    end
  end

  let( :env ) do
    { 'PATH_INFO' => '/users',
      'SCRIPT_NAME' => '/users',
    }
  end

  let( :guard ) do
    guard = Ixtlan::UserManagement::Guard.new
    Cuba[ :guard ] =  Proc.new do |groups|
      guard
    end
    guard
  end

  describe 'guarded context with nested context' do
    
    it 'should raise error' do
      env = { 'PATH_INFO' => '/users/accounts',
           'SCRIPT_NAME' => '/users/accounts' }

      user = guard.permission_for( 'users' ) do |u|
        u.allow_all
      end
      guard.permission_for( 'admins' ) do |a|
        a.parent = user
        a.allow_all
      end

      env[ 'REQUEST_METHOD' ] = 'GET'
      lambda{ Cuba.call( env ) }.must_raise RuntimeError
    end

    it 'allow all' do
      env = { 'PATH_INFO' => '/users/accounts',
           'SCRIPT_NAME' => '/users/accounts' }
      user = guard.permission_for( 'users' ) do |u|
        u.allow_all
      end
      guard.permission_for( 'accounts' ) do |a|
        a.parent = user
        a.allow_all
      end

      env[ 'REQUEST_METHOD' ] = 'GET'
      _, _, resp = Cuba.call( env )
      resp.join.must.eq 'get accounts'

      [ 'POST','PUT', 'DELETE' ].each do |m|
        env[ 'REQUEST_METHOD' ] = m
        status, _, resp = Cuba.call( env )
        resp.must.be :empty?
        status.must.eq 200
      end
    end

  end

  describe 'guarded context with association' do

    let( :env ) do
      { 'PATH_INFO' => '/users/42',
        'SCRIPT_NAME' => '/users/42',
      }
    end

    it 'denies all requests without associated id' do
      guard.permission_for( 'users' ) do |u|
        u.allow_all( 42 )
      end

      ['GET', 'POST','PUT', 'DELETE' ].each do |m|
        env[ 'REQUEST_METHOD' ] = m
        _, _, resp = Cuba.call( env )
        resp.join.must.eq m.downcase + '42'
      end
    end

    it 'denies all requests with wrong associated id' do
      guard.permission_for( 'users', 13 ) do |u|
        u.allow_all
      end

      ['GET', 'POST','PUT', 'DELETE' ].each do |m|
        env[ 'REQUEST_METHOD' ] = m
        _, _, resp = Cuba.call( env )
        resp.join.must.eq 'Forbidden'
      end

      env[ 'PATH_INFO' ] = '/users'
      env[ 'SCRIPT_NAME' ] = '/users'
      env[ 'REQUEST_METHOD' ] = 'GET'
      _, _, resp = Cuba.call( env )
      resp.join.must.eq 'get["13"]'
    end

    it 'allows all requests with associated id' do
      guard.permission_for( 'users', 42 ) do |u|
        u.allow_all
      end

      ['GET', 'POST','PUT', 'DELETE' ].each do |m|
        env[ 'REQUEST_METHOD' ] = m
        _, _, resp = Cuba.call( env )
        resp.join.must.eq m.downcase + '42'
      end

      env[ 'PATH_INFO' ] = '/users'
      env[ 'SCRIPT_NAME' ] = '/users'
      env[ 'REQUEST_METHOD' ] = 'GET'
      _, _, resp = Cuba.call( env )
      resp.join.must.eq 'get["42"]'
    end
  end

  describe 'guarded context' do
    it 'forbids all request' do
      Cuba[ :guard ] = nil
      ['GET', 'POST','PUT', 'DELETE' ].each do |m|
        env[ 'REQUEST_METHOD' ] = m
        _, _, resp = Cuba.call( env )
        resp.join.must.eq 'Forbidden'
      end
    end

    it 'allows all request' do
      guard.permission_for( 'users' ) do |u|
        u.allow_all
      end

      ['GET', 'POST','PUT', 'DELETE' ].each do |m|
        env[ 'REQUEST_METHOD' ] = m
        _, _, resp = Cuba.call( env )
        resp.join.must.eq m.downcase
      end
    end

    it 'allows retrieve' do
      guard.permission_for( 'users' ) do |u|
        u.allow_retrieve
      end
      
      m = 'GET'
      env[ 'REQUEST_METHOD' ] = m
      _, _, resp = Cuba.call( env )
      resp.join.must.eq m.downcase
      
      ['POST','PUT', 'DELETE' ].each do |m|
        env[ 'REQUEST_METHOD' ] = m
        _, _, resp = Cuba.call( env )
        resp.join.must.eq 'Forbidden'
      end
    end
    
    it 'allows retrieve and create' do
      guard.permission_for( 'users' ) do |u|
        u.allow_retrieve
        u.allow_create
      end
      ['GET','POST' ].each do |m|
        env[ 'REQUEST_METHOD' ] = m
        _, _, resp = Cuba.call( env )
        resp.join.must.eq m.downcase
      end
      ['PUT', 'DELETE' ].each do |m|
        env[ 'REQUEST_METHOD' ] = m
        _, _, resp = Cuba.call( env )
        resp.join.must.eq 'Forbidden'
      end
    end

    it 'allows retrieve and create and update' do
      guard.permission_for( 'users' ) do |u|
        u.allow_mutate
      end
      ['GET', 'POST','PUT' ].each do |m|
        env[ 'REQUEST_METHOD' ] = m
        _, _, resp = Cuba.call( env )
        resp.join.must.eq m.downcase
      end
      env[ 'REQUEST_METHOD' ] = 'DELETE'
      _, _, resp = Cuba.call( env )
      resp.join.must.eq 'Forbidden'
    end

    it 'allows retrieve and create and update and delete' do
      guard.permission_for( 'users' ) do |u|
        u.allow_mutate
        u.allow_delete
      end
      ['GET', 'POST','PUT', 'DELETE' ].each do |m|
        env[ 'REQUEST_METHOD' ] = m
        _, _, resp = Cuba.call( env )
        resp.join.must.eq m.downcase
      end
    end
  end
end
