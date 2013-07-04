require 'test_helper'

class DeleteTest < MiniTest::Unit::TestCase
  def link
    'http://example.com/foo'
  end

  def link_url
    documents_url(link: link)
  end

  def stub_successful_delete_request
    stub_request(:delete, link_url).to_return(status(200))
  end

  def stub_one_failed_delete_request
    stub_request(:delete, link_url).
      to_return(status(502)).times(1).then.to_return(status(200))
  end

  def test_should_delete_a_document_by_its_link
    stub_successful_delete_request
    index = Rummageable::Index.new(rummager_url, index_name)
    index.delete(link)
    assert_requested :delete, link_url do |request|
      request.headers['Content-Type'] == 'application/json' &&
        request.headers['Accept'] == 'application/json'
    end
  end

  def test_should_be_able_to_delete_all_documents
    stub_request(:delete, /#{documents_url}/).to_return(status(200))
    index = Rummageable::Index.new(rummager_url, index_name)
    index.delete_all
    assert_requested :delete, documents_url, query: { delete_all: 1 } do |request|
      request.headers['Content-Type'] == 'application/json' &&
        request.headers['Accept'] == 'application/json'
    end
  end

  def test_delete_should_handle_connection_errors
    stub_one_failed_delete_request
    Rummageable::Index.any_instance.expects(:sleep).once
    index = Rummageable::Index.new(rummager_url, index_name)
    index.delete(link)
    assert_requested :delete, link_url, times: 2
  end

  def test_delete_should_log_attempts_to_delete_documents_from_rummager
    stub_successful_delete_request
    logger = stub('logger')
    logger.expects(:info).twice
    index = Rummageable::Index.new(rummager_url, index_name, logger: logger)
    index.delete(link)
  end
end
