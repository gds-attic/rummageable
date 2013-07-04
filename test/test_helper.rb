require 'minitest/autorun'
require 'mocha/setup'
require 'webmock/minitest'
require 'rummageable'

ENV['RACK_ENV'] = 'test'

class MiniTest::Unit::TestCase
  def rummager_url
    Plek.current.find('search')
  end

  def index_name
    'index-name'
  end

  def documents_url(index = index_name)
    "#{rummager_url}/#{index}/documents"
  end

  def with_whitehall_rummager_service
    original_rummager_service_name = Rummageable.rummager_service_name
    Rummageable.rummager_service_name = 'whitehall-search'
    yield
  ensure
    Rummageable.rummager_service_name = original_rummager_service_name
  end
end
