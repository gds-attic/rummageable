require 'test_helper'

class AddTest < MiniTest::Unit::TestCase
  def build_document(index)
    {
      'title' => "TITLE #{index}",
      'link' => "/link#{index}"
    }
  end

  def one_document
    build_document(1)
  end

  def two_documents
    [one_document] << build_document(2)
  end

  def stub_successful_request
    stub_request(:post, documents_url).to_return(status(200))
  end

  def stub_one_failed_request
    stub_request(:post, documents_url).
      to_return(status(502)).times(1).then.to_return(status(200))
  end

  def stub_repeatedly_failing_requests(failures)
    stub_request(:post, documents_url).to_return(status(502)).times(failures)
  end

  def test_add_should_index_a_single_document_by_posting_it_as_json
    stub_successful_request
    index = Rummageable::Index.new(rummager_url, index_name)
    index.add(one_document)
    assert_requested :post, documents_url, times: 1 do |request|
      request.body == json_for([one_document]) &&
        request.headers['Content-Type'] == 'application/json' &&
        request.headers['Accept'] == 'application/json'
    end
  end

  def test_add_batch_should_index_multiple_documents_in_one_request
    stub_successful_request
    index = Rummageable::Index.new(rummager_url, index_name)
    index.add_batch(two_documents)
    assert_requested :post, documents_url, body: json_for(two_documents)
  end

  def test_add_batch_should_split_large_batches_into_multiple_requests
    stub_successful_request
    documents = (1..3).map { |i| build_document(i) }
    index = Rummageable::Index.new(rummager_url, index_name, batch_size: 2)
    index.add_batch(documents)
    assert_requested :post, documents_url, body: json_for(documents[0, 2])
    assert_requested :post, documents_url, body: json_for(documents[2, 1])
  end

  def test_add_should_return_true_when_successful
    stub_successful_request
    index = Rummageable::Index.new(rummager_url, index_name)
    assert index.add(one_document), 'should return true on success'
  end

  def test_add_should_sleep_and_retry_on_bad_gateway_errors
    stub_one_failed_request
    Rummageable::Index.any_instance.expects(:sleep).with(1)
    index = Rummageable::Index.new(rummager_url, index_name, retry_delay: 1)
    assert index.add(one_document), 'should return true on success'
    assert_requested :post, documents_url, times: 2
  end

  def test_add_should_not_sleep_between_attempts_if_retry_delay_nil
    stub_one_failed_request
    Rummageable::Index.any_instance.expects(:sleep).never
    index = Rummageable::Index.new(rummager_url, index_name, retry_delay: nil)
    index.add(one_document)
    assert_requested :post, documents_url, times: 2
  end

  def test_add_should_propogate_exceptions_after_too_many_failed_attempts
    failures = attempts = 2
    stub_repeatedly_failing_requests(failures)
    Rummageable::Index.any_instance.stubs(:sleep)
    index = Rummageable::Index.new(rummager_url, index_name, attempts: attempts)
    assert_raises RestClient::BadGateway do
      index.add(one_document)
    end
  end

  def test_add_should_log_attempts_to_post_to_rummager
    stub_successful_request
    logger = stub('logger', debug: true)
    logger.expects(:info).twice
    index = Rummageable::Index.new(rummager_url, index_name, logger: logger)
    index.add(one_document)
  end

  def test_add_should_log_failures
    stub_one_failed_request
    Rummageable::Index.any_instance.stubs(:sleep)
    logger = stub('logger', debug: true, info: true)
    logger.expects(:warn).once
    index = Rummageable::Index.new(rummager_url, index_name, logger: logger)
    index.add(one_document)
  end
end
