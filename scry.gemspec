# -*- encoding: utf-8 -*-
require File.expand_path('../lib/scry/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Scott Sanders"]
  gem.email         = ["ssanders@taximagic.com"]
  gem.description   = %q{Scry provides a mechanism for an application to use divination to discover knowledge about dependent services and configuration.}
  gem.summary       = File.read(File.expand_path('../README.md', __FILE__))
  gem.homepage      = "https://github.com/ridecharge/scry"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "scry"
  gem.require_paths = ["lib"]
  gem.version       = Scry::VERSION

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec-core"
  gem.add_development_dependency "guard-rspec"
end
