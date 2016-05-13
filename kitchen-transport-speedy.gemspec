# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kitchen/transport/speedy/version'

Gem::Specification.new do |spec|
  spec.name          = "kitchen-transport-speedy"
  spec.version       = Kitchen::Transport::SpeedyModule::VERSION
  spec.authors       = ["Grégoire Seux"]
  spec.email         = ["g.seux@criteo.com"]

  spec.summary       = %q{Fast transport for test-kitchen using archiving}

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'test-kitchen'

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
end
