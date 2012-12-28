require 'spec_helper'
require 'cuba_api/write_aspect'
require 'cuba_api/accept_content'

class B
  def method_missing( method, *args )
    method.to_s
  end
end

describe CubaApi::AcceptContent do

  before do
    Cuba.reset!
    Cuba.plugin CubaApi::Config
    Cuba[ :aspects ] = []
    Cuba.plugin CubaApi::WriteAspect
    Cuba.plugin CubaApi::AcceptContent
    Cuba.accept :yaml
    Cuba.define do
      on default do
        write B.new
      end
    end
  end

  it 'creates yaml' do
     _, _, resp = Cuba.call({"SCRIPT_NAME" => "/bla.yaml"})
    resp.must.eq ["--- !ruby/object:B {}\n"]

    _, _, resp = Cuba.call({"HTTP_ACCEPT" => "application/x-yaml"})
    resp.must.eq ["--- !ruby/object:B {}\n"]

    _, _, resp = Cuba.call({"HTTP_ACCEPT" => "text/yaml"})
    resp.must.eq ["--- !ruby/object:B {}\n"]
  end

  it 'gives not found for not configured xml' do
    status, _, _ = Cuba.call({"SCRIPT_NAME" => "/bla.xml"})
    status.must.eq 404

    status, _, _ = Cuba.call({"HTTP_ACCEPT" => "application/xml"})
    status.must.eq 404
  end

  it 'gives preference to script extension' do
    _, _, resp = Cuba.call({"SCRIPT_NAME" => "/bla.yaml", "HTTP_ACCEPT" => "application/xml"})
    resp.must.eq ["--- !ruby/object:B {}\n"]

    status, _, _ = Cuba.call({"SCRIPT_NAME" => "/bla.xml", "HTTP_ACCEPT" => "application/x-yaml"})
    status.must.eq 404
  end
end
