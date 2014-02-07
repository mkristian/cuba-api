#-*- mode: ruby -*-

gemspec

properties( 'jruby.versions' => '1.5.6, 1.6.8, 1.7.10',
            'jruby.modes' => '1.8, 1.9, 2.0',
            'jruby.plugins.version' => '1.0.0-rc4' )

jruby_plugin :minitest do
  execute_goals :spec
end

# vim: syntax=Ruby
