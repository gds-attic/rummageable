require 'minitest/autorun'
require 'webmock/minitest'
require 'rummageable'

ENV['RACK_ENV'] = 'test'

class MiniTest::Unit::TestCase
  API = Plek.current.find("search")

  def with_whitehall_rummager_service
    original_rummager_service_name = Rummageable.rummager_service_name
    Rummageable.rummager_service_name = "whitehall-search"
    yield
  ensure
    Rummageable.rummager_service_name = original_rummager_service_name
  end
end
