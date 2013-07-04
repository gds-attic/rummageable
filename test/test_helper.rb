require 'minitest/autorun'
require 'mocha/setup'
require 'webmock/minitest'
require 'rummageable'

ENV['RACK_ENV'] = 'test'

class MiniTest::Unit::TestCase
  def json_for(documents)
    MultiJson.encode(documents)
  end

  def rummager_url
    Plek.current.find('search')
  end

  def index_name
    'index-name'
  end

  def documents_url(options = {})
    parts = rummager_url, options.fetch(:index, index_name), 'documents'
    parts << CGI.escape(options[:link]) if options[:link]
    parts.join('/')
  end

  def link_url
    documents_url(link: link)
  end

  def status(http_code)
    {
      200 => { status: 200, body: '{"result":"OK"}' },
      502 => { status: 502, body: 'Bad gateway' }
    }.fetch(http_code)
  end

  def with_whitehall_rummager_service
    original_rummager_service_name = Rummageable.rummager_service_name
    Rummageable.rummager_service_name = 'whitehall-search'
    yield
  ensure
    Rummageable.rummager_service_name = original_rummager_service_name
  end
end
