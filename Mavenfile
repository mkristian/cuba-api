#-*- mode: ruby -*-

gemspec

properties( 'jruby.versions' => '1.5.6,1.6.8,1.7.4',
            'jruby.18and19' => 'true',
            'jruby.plugins.version' => '1.0.0-rc3' )

jruby_plugin :minitest do
  execute_goals :spec
end
# vim: syntax=Ruby
