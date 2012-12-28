require 'spec_helper'
require 'cuba_api/config'

describe CubaApi::Config do

  before do
    Cuba.reset!
    Cuba.plugin CubaApi::Config
    Cuba[ :main ] = Cuba.method( :define )
    Cuba[ :name ] = :root
    class Other < Cuba; end
  end

  after { Cuba.config.clear }

  it 'should overwrite super-cuba' do
    Other[ :main ] = :other

    Cuba[ :main ].class.must.eq Method
    Other[ :main ].must.eq :other
  end

  it 'should inherit super-cuba on new attributes' do
    Cuba[ :more ] = :more

    Cuba[ :more ].must.eq :more
    Other[ :more ].must.eq :more
  end

  it 'should see config from super-cuba' do
    Cuba[ :name ].must.eq :root
    Other[ :name ].must.eq :root
  end
end
