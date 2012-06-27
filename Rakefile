require 'rake/testtask'

require "bundler/gem_tasks"
require "gem_publisher"

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end

task :publish_gem do |t|
  gem = GemPublisher.publish_if_updated("rummageable.gemspec", :rubygems)
  puts "Published #{gem}" if gem
end


task :default => :test
