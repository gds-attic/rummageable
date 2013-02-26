lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'rummageable/version'

Gem::Specification.new do |s|
  s.name = "rummageable"
  s.version = Rummageable::VERSION
  s.authors = ["GovUK Beta Team"]
  s.description = "Mediator for apps that want their content to be in the search index"
  s.files = Dir["lib/**/*.rb"]
  s.homepage = "https://github.com/alphagov/rummageable"
  s.require_paths = ["lib"]
  s.summary = "Mediator for apps that want their content to be in the search index"
  s.test_files = Dir["test/**/*_test.rb"]
  s.add_dependency "yajl-ruby"
  s.add_dependency "multi_json"
  s.add_dependency "rest-client"
  s.add_dependency "plek", '>= 0.5.0'
  s.add_development_dependency "rake"
  s.add_development_dependency "webmock"
  s.add_development_dependency "gem_publisher", "1.0.0"
end
