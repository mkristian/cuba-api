require 'spec_helper'
require 'cuba_api/config'
require 'cuba_api/utils'
require 'cuba_api/write_aspect'
require 'cuba_api/accept_content'
require 'yaml'

class B
  def method_missing( method, *args )
    method.to_s
  end
end

describe CubaApi::AcceptContent do

  before do
    Cuba.reset!
    Cuba.plugin CubaApi::Config
    Cuba.plugin CubaApi::Utils
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
    skip("to_yaml add extra line with ...") if defined?( JRUBY_VERSION ) and (( JRUBY_VERSION =~ /^1.6./ ) == 0 ) and ( nil == (RUBY_VERSION =~ /^1.8/) )

     _, _, resp = Cuba.call({"SCRIPT_NAME" => "/bla.yaml"})
    resp[ 0 ] = resp[ 0 ].sub(/.*!/, "---!").sub( /\n\n/, "\n")
    resp.join.must.eq "Not Found"

    _, _, resp = Cuba.call({"HTTP_ACCEPT" => "application/x-yaml"})
    resp[ 0 ] = resp[ 0 ].sub(/.*!/, "---!").sub( /\n\n/, "\n")
    resp.join.must.eq "---!ruby/object:B {}\n"

    _, _, resp = Cuba.call({"HTTP_ACCEPT" => "text/yaml"})
    resp[ 0 ] = resp[ 0 ].sub(/.*!/, "---!").sub( /\n\n/, "\n")
    resp.join.must.eq "---!ruby/object:B {}\n"
  end

  it 'gives not found for not configured xml' do
    status, _, _ = Cuba.call({"SCRIPT_NAME" => "/bla.xml"})
    status.must.eq 404

    status, _, _ = Cuba.call({"HTTP_ACCEPT" => "application/xml"})
    status.must.eq 404
  end

  it 'gives preference to script extension' do
    skip("to_yaml add extra line with ...") if defined?( JRUBY_VERSION ) and (( JRUBY_VERSION =~ /^1.6./ ) == 0 ) and ( nil == (RUBY_VERSION =~ /^1.8/) )

    status, _, resp = Cuba.call({"SCRIPT_NAME" => "/bla.yaml", "HTTP_ACCEPT" => "application/xml"})
    resp[ 0 ] = resp[ 0 ].sub(/.*!/, "---!").sub( /\n\n/, "\n")
    resp.join.must.eq "Not Found"
    status.must.eq 404
  end
end
