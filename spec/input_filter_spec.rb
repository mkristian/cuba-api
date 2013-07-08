require 'spec_helper'
require 'cuba_api/input_filter'
require 'ixtlan/babel/params_filter'
require 'json'
require 'stringio'

class D

  attr_accessor :attributes

  def initialize( args )
    @attributes = args
  end
end

class DFilter < Ixtlan::Babel::ParamsFilter

  add_context( :single, :only => [:name], :keep => [:age] )
  add_context( :update, :only => [:message], :keep => [:age] )

end

describe CubaApi::InputFilter do

  before do
    Cuba.reset!
    Cuba.plugin CubaApi::InputFilter
    Cuba.define do
      on post do
        attr = req_filter( D ).new_model.attributes
        # whether hash is ordered-hash should not matter
        res.write attr.keys.sort.collect {|k| attr[k] }.join
      end
      on default do
        filter = req_filter( D, :update )
        res.write filter.params['message'].to_s + filter.age.to_s
      end
    end
  end

  it 'no json input' do
     _, _, resp = Cuba.call({})
    resp.join.must.be :empty?
  end

  it 'json input with attr and without keep' do
     _, _, resp = Cuba.call( 'CONTENT_TYPE' => 'application/json',
                             'rack.input' => StringIO.new( '{"name":"me","message":"be happy"}' ) )
    resp.join.must.eq 'be happy'
  end

  it 'json input with attr and  with keep' do
     _, _, resp = Cuba.call( 'CONTENT_TYPE' => 'application/json',
                             'rack.input' => StringIO.new( '{"name":"me","message":"be happy","age":45}' ) )
    resp.join.must.eq 'be happy' + "45"
  end

  it 'json input without attr and without keep' do
     _, _, resp = Cuba.call( 'CONTENT_TYPE' => 'application/json',
                             'rack.input' => StringIO.new( '{"something":"else"}' ) )
    resp.join.must.be :empty?
  end

  it 'json input without attr and with keep' do
     _, _, resp = Cuba.call( 'CONTENT_TYPE' => 'application/json',
                             'rack.input' => StringIO.new( '{"something":"else","age":45}' ) )
    resp.join.must.eq "45"
  end

  it 'create new instance with json input' do
     _, _, resp = Cuba.call( 'CONTENT_TYPE' => 'application/json',
                             'REQUEST_METHOD' => 'POST',
                             'rack.input' => StringIO.new( '{"name":"me","message":"be happy","age":45}' ) )
    resp.join.must.eq 'me'
  end

end
