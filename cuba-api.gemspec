# -*- mode: ruby -*-
Gem::Specification.new do |s|
  s.name = 'cuba-api'
  s.version = '0.1.0'

  s.summary = 'set of plugins for usng cuba as API server'
  s.description = ''
  s.homepage = 'http://github.com/mkristian/cuba-api'

  s.authors = ['Christian Meier']
  s.email = ['m.kristian@web.de']

  s.files = Dir['MIT-LICENSE']
  s.license = 'MIT'
  s.files += Dir['README.md']
  s.files += Dir['lib/**/*']
  #s.test_files += Dir['spec/**/*_spec.rb']
  s.add_dependency 'cuba', '~> 3.1'
  s.add_dependency 'ixtlan-babel', '~> 0.2.0'
  s.add_development_dependency "copyright-header", '~> 1.0.7'
  s.add_development_dependency "minitest", '~> 4.3.0'
  s.add_development_dependency 'mustard', '~> 0.1'
end

# vim: syntax=Ruby
