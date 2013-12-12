require 'spec_helper'
require 'cuba_api/aspects'
require 'cuba_api/config'
require 'cuba_api/loggers'
require 'cuba_api/aspects/response_status'

class E

  def id
    4711
  end

  def initialize( args = nil )
    @errors = (args || {}).delete( :errors ) || {}
    # ruby18 workaround
    def @errors.to_s
      inspect
    end
    @attributes = args
  end
    
  def deleted?
    @attrbutes.nil?
  end

  def errors
    @errors
  end

  def to_s
    @attributes.inspect + @errors.inspect
  end
end


describe CubaApi::ResponseStatus do

  before do
    Cuba.reset!
    Cuba.plugin CubaApi::Config
    Cuba.plugin CubaApi::Loggers
    Cuba.plugin CubaApi::Aspects
    Cuba.plugin CubaApi::ResponseStatus
    Cuba.define do
      on get do
        write E.new :errors => { :name => 'missing name' }
      end
      on post do
        write E.new :message => 'be happy' 
      end
      on put do
        write E.new :message => 'be happy' 
      end
      on delete do
        write E.new
      end
    end
  end

  it 'status 200' do
    status, _, resp = Cuba.call({'REQUEST_METHOD' => 'PUT'})
    status.must.eq 200
    resp.join.must.eq "{:message=>\"be happy\"}{}"
  end

  it 'status 201' do
    status, _, resp = Cuba.call({'REQUEST_METHOD' => 'POST'})
    status.must.eq 201
    resp.join.must.eq "{:message=>\"be happy\"}{}"
  end

  it 'status 204' do
    status, _, resp = Cuba.call({'REQUEST_METHOD' => 'DELETE'})
    status.must.eq 204
    resp.join.must.be :empty?
  end

  it 'status 412' do
    status, _, resp = Cuba.call({'REQUEST_METHOD' => 'GET'})
    status.must.eq 412
    resp.join.must.eq "{:name=>\"missing name\"}"
  end

end
