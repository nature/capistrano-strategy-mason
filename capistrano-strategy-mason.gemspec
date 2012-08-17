# -*- encoding: utf-8 -*-
require File.expand_path('../lib/capistrano-strategy-mason/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Chris Lowder"]
  gem.email         = ["clowder@gmail.com"]
  gem.description   = %q{Mason deployments from capistrano.}
  gem.summary       = gem.description
  gem.homepage      = "https://github.com/nature/capistrano-strategy-mason"

  gem.files         = ['LICENSE',
                       'README.md',
                       'lib/capistrano-strategy-mason.rb',
                       'lib/capistrano-strategy-mason/version.rb',
                       'lib/capistrano/recipes/deploy/strategy/mason.rb']
  gem.name          = "capistrano-strategy-mason"
  gem.require_paths = ["lib"]
  gem.version       = Capistrano::Strategy::Mason::VERSION
end
