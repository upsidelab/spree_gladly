# frozen_string_literal: true

require_relative "lib/spree_gladly/version"

Gem::Specification.new do |spec|
  spec.name          = "spree_gladly"
  spec.version       = SpreeGladly::VERSION
  spec.author       = 'Upsidelab.io'
  spec.email        = 'hello@upsidelab.io'

  spec.summary       = 'Spree Connector API'
  spec.homepage      = "http://upsidelab.io"

  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")
  spec.metadata["homepage_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'spree_core'
  spec.add_dependency 'spree_extension'
  spec.add_dependency 'dry-validation'
  spec.add_dependency 'jsonapi-serializer'

  spec.add_development_dependency 'dotenv-rails'
  spec.add_development_dependency 'spree_dev_tools'
end
