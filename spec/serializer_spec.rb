require 'spec_helper'
require 'cuba_api/config'
require 'cuba_api/write_aspect'
require 'cuba_api/serializer'
require 'yaml'
require 'ixtlan/babel/serializer'

class A
  def attributes
    { :name => 'me and the corner' }
  end
end
class ASerializer < Ixtlan::Babel::Serializer
end
module ToYaml
  def to_yaml( obj, opts )
    obj.to_yaml
  end
end

describe CubaApi::Serializer do

  before do
    Cuba.reset!
    Cuba.plugin CubaApi::Config
    Cuba[ :aspects ] = []
    Cuba.plugin CubaApi::WriteAspect
    Cuba.plugin CubaApi::Serializer
    Cuba.plugin ToYaml
    Cuba.append_aspect :to_yaml
    Cuba.define do
      on default do
        write A.new
      end
    end
  end

  it 'should write out yaml' do
     _, _, resp = Cuba.call({})
    
    resp[ 0 ] = resp[ 0 ].sub(/.*\n/, "---\n")
    resp.must_equal ["---\nname: me and the corner\n"]
  end
end
