Gem::Specification.new do |s|
  s.name = "rummageable"
  s.version = "0.1.2"
  s.authors = ["GovUK Beta Team"]
  s.description = "Mediator for apps that want their content to be in the search index"
  s.files = Dir["lib/**/*.rb"]
  s.homepage = "https://github.com/alphagov/rummageable"
  s.require_paths = ["lib"]
  s.summary = "Mediator for apps that want their content to be in the search index"
  s.test_files = Dir["test/**/*_test.rb"]
  s.add_dependency "json"
  s.add_dependency "rest-client"
  s.add_dependency "plek"
  s.add_development_dependency "rake"
  s.add_development_dependency "webmock"
end
