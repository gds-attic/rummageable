require 'test_helper'

class AddTest < MiniTest::Unit::TestCase
  def build_document(index)
    {
      "title" => "TITLE #{index}",
    }
  end

  def one_document
    build_document(1)
  end

  def two_documents
    [one_document] << build_document(2)
  end

  def json_for(documents)
    MultiJson.encode(documents)
  end

  def status_ok
    { status: 200, body: '{"result":"OK"}' }
  end

  def setup
    @index = Rummageable::Index.new(rummager_url, index_name)
  end

  def test_add_should_index_a_single_document_by_posting_it_as_json
    stub_request(:post, search_url).
      with(body: json_for([one_document])).to_return(status_ok)
    @index.add(one_document)
    assert_requested :post, search_url, times: 1
  end

  def test_add_batch_should_index_multiple_documents_by_posting_them_as_json
    stub_request(:post, search_url).
      with(body: json_for(two_documents)).to_return(status_ok)
    @index.add_batch(two_documents)
    assert_requested :post, search_url, times: 1
  end

  def test_add_batch_should_send_documents_in_batches_of_20
    stub_request(:post, search_url).to_return(status_ok)
    documents = (1..21).map { |i| build_document(i) }
    @index.add_batch(documents)
    assert_requested :post, search_url, body: json_for(documents[0, 20])
    assert_requested :post, search_url, body: json_for(documents[20, 1])
  end
end
