# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'telagiana'
  spec.version = '0.5.3'
  spec.authors = ['don Piotr Talarczyk']
  spec.email = ['don.piotr@netc.it']

  spec.summary = 'A Ruby widget library for Gosu with automatic layout'
  spec.description = 'TelaGiana is a Ruby widget library for Gosu that simplifies creating user interfaces with automatic layout. It provides ready-to-use widgets like buttons, input fields, headers, paragraphs, and containers with built-in focus management and event handling.'
  spec.homepage = 'https://github.com/donPiotr/telagiana'
  spec.license = 'LGPL-3.0-or-later'

  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob("{lib,example}/**/*") + %w[README.md LICENSE telagiana.gemspec]
  spec.files.select! { |f| File.file?(f) }

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Runtime dependencies
  spec.add_runtime_dependency 'gosu', '~> 1.4'

  # Development dependencies
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.21'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
