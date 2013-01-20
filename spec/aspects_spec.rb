require 'spec_helper'
require 'cuba_api/config'
require 'cuba_api/write_aspect'

module Plugin
  def one( obj, opts )
    obj + "-one"
  end
  def two( obj, opts )
    obj + "-two"
  end
  def three( obj, opts )
    obj + "-three"
  end
end

describe CubaApi::WriteAspect do

  before do
    Cuba.reset!
    Cuba.plugin CubaApi::Config
    Cuba[ :aspects ] = []
    Cuba.plugin CubaApi::WriteAspect
    Cuba.plugin Plugin
    Cuba.append_aspect :one
    Cuba.prepend_aspect :two
    Cuba.append_aspect :three
    Cuba.define do
      on true do
        write 'start'
      end
    end
  end

  after { Cuba.config.clear }
  
  it 'should execute aspects in the right order' do
     _, _, resp = Cuba.call({})

    resp.join.must.eq "start-two-one-three"
  end
end
