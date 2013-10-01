# -*- mode: ruby -*-
Gem::Specification.new do |s|
  s.name = 'cuba-api'
  s.version = '0.5.1'

  s.summary = 'set of plugins for using cuba as API server'
  s.description = 'add content negogiation, serialization of objects (their attributes map), and some helpers for authentication + authorization to the cuba framework'
  s.homepage = 'http://github.com/mkristian/cuba-api'

  s.authors = ['Christian Meier']
  s.email = ['m.kristian@web.de']

  s.license = 'MIT'

  s.files = Dir['MIT-LICENSE']
  s.files += Dir['README.md']
  s.files += Dir['lib/**/*']
  s.files += Dir['spec/**/*']
  s.files += Dir['Gemfile']

  s.test_files += Dir['spec/**/*_spec.rb']

  s.add_dependency 'cuba', '~> 3.1'
  s.add_dependency 'ixtlan-babel', '~> 0.4'
  s.add_dependency 'safe_yaml', '~> 0.8'
  s.add_dependency 'multi_json', '~> 1.6'
  s.add_development_dependency 'json', '~> 1.6'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'minitest', '~> 4.0'
  s.add_development_dependency 'mustard', '~> 0.1'
  s.add_development_dependency 'backports', '~> 2.6'
end

# vim: syntax=Ruby
