require 'test_helper'

class AddTest < MiniTest::Unit::TestCase
  def build_document(index)
    {
      "title" => "TITLE #{index}",
      "description" => "DESCRIPTION",
      "format" => "NAME OF FORMAT",
      "section" => "NAME OF SECTION",
      "subsection" => "NAME OF SUBSECTION",
      "subsubsection" => "NAME OF SUBSUBSECTION",
      "link" => "/link",
      "indexable_content" => "TEXT",
      "boost_phrases" => "BOOST"
    }
  end

  def one_document
    [build_document(1)]
  end

  def two_documents
    one_document << build_document(2)
  end

  def twenty_one_documents
    (1..21).map { |i| build_document(i) }
  end

  def json_for(documents)
    MultiJson.encode(documents)
  end

  def test_should_index_a_single_document_by_posting_it_as_json
    stub_request(:post, "#{API}/documents").
      with(body: json_for(one_document)).
      to_return(status: 200, body: '{"result":"OK"}')
    Rummageable.index(one_document)
  end

  def test_should_index_multiple_documents_by_posting_them_as_json
    stub_request(:post, "#{API}/documents").
      with(body: json_for(two_documents)).
      to_return(status: 200, body: '{"result":"OK"}')
    Rummageable.index(two_documents)
  end

  def test_should_send_documents_in_batches_of_20
    stub_request(:post, "#{API}/documents").
      to_return(status: 200, body: '{"result":"OK"}')
    documents = twenty_one_documents
    Rummageable.index(documents)
    assert_requested :post, "#{API}/documents", body: json_for(documents[0, 20])
    assert_requested :post, "#{API}/documents", body: json_for(documents[20, 1])
  end

  def test_should_raise_an_exception_if_a_document_has_symbol_keys
    assert_raises Rummageable::InvalidDocument do
      Rummageable.index({ title: "TITLE" })
    end
  end

  def test_should_raise_an_exception_if_a_document_has_unrecognised_keys
    assert_raises Rummageable::InvalidDocument do
      Rummageable.index({ 'unknown_key' => 'value' })
    end
  end

  def test_allows_indexing_to_an_alternative_index
    stub_request(:post, "#{API}/alternative/documents").
      with(body: json_for(one_document)).
      to_return(status: 200, body: '{"result":"OK"}')

    Rummageable.index(one_document, "/alternative")
  end

  def test_should_post_to_rummageable_host_determined_by_rummager_service_name
    stub_request(:post, "#{API}/documents")
    stub_request(:post, "#{Plek.current.find("whitehall-search")}/documents")
    with_rummager_service_name("whitehall-search") do
      Rummageable.index(one_document)
    end
    assert_not_requested(:post, "#{API}/documents")
    assert_requested(:post, "#{Plek.current.find("whitehall-search")}/documents")
  end
end
