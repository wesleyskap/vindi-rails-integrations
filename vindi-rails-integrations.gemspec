# frozen_string_literal: true

require_relative "lib/vindi/integrations/version"

Gem::Specification.new do |spec|
  spec.name = "vindi-rails-integrations"
  spec.version = Vindi::Integrations::VERSION
  spec.authors = ["Wesley Lima"]
  spec.email = ["wesleyskap@gmail.com"]

  spec.summary = "Rails backend integrations (webhooks, jobs, sync) for Vindi API."
  spec.description = "Provides webhook handling, background jobs, and data synchronization for the Vindi Rails SDK."
  spec.homepage = "https://github.com/wesleyskap/vindi-rails-integrations"
  spec.metadata["changelog_uri"] = "https://github.com/wesleyskap/vindi-rails-integrations/blob/master/CHANGELOG.md"

  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir["lib/**/*", "README.md", "LICENSE.txt"]
  spec.require_paths = ["lib"]

  spec.add_dependency "vindi-rails", ">= 0.2.0"
  spec.add_dependency "railties", ">= 6.0"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "activerecord", ">= 6.0"
  spec.add_development_dependency "activejob", ">= 6.0"
  spec.add_development_dependency "actionpack", ">= 6.0"

end
