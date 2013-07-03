require 'test_helper'

class AddTest < MiniTest::Unit::TestCase
  def test_should_index_a_single_document_by_posting_it_as_json
    document = {
      "title" => "TITLE",
      "description" => "DESCRIPTION",
      "format" => "NAME OF FORMAT",
      "section" => "NAME OF SECTION",
      "subsection" => "NAME OF SUBSECTION",
      "subsubsection" => "NAME OF SUBSUBSECTION",
      "link" => "/link",
      "indexable_content" => "TEXT",
      "boost_phrases" => "BOOST"
    }
    json = MultiJson.encode([document])

    stub_request(:post, "#{API}/documents").
      with(body: json).
      to_return(status: 200, body: '{"result":"OK"}')

    Rummageable.index(document)
  end

  def test_should_index_multiple_documents_by_posting_them_as_json
    documents = [
      {"title" => "DOC1"},
      {"title" => "DOC2"}
    ]
    json = MultiJson.encode(documents)

    stub_request(:post, "#{API}/documents").
      with(body: json).
      to_return(status: 200, body: '{"result":"OK"}')

    Rummageable.index(documents)
  end

  def test_should_send_documents_in_batches_of_20
    documents = 21.times.map { |i| {"title" => "DOC#{i}"} }

    stub_request(:post, "#{API}/documents").
      to_return(status: 200, body: '{"result":"OK"}')

    Rummageable.index(documents)
    assert_requested :post, "#{API}/documents", body: MultiJson.encode(documents[0, 20])
    assert_requested :post, "#{API}/documents", body: MultiJson.encode(documents[20, 1])
  end

  def test_should_raise_an_exception_if_a_document_has_symbol_keys
    document = {title: "TITLE"}
    assert_raises Rummageable::InvalidDocument do
      Rummageable.index(document)
    end
  end

  def test_should_raise_an_exception_if_a_document_has_unrecognised_keys
    document = {"foo" => "bar"}
    assert_raises Rummageable::InvalidDocument do
      Rummageable.index(document)
    end
  end

  def test_allows_indexing_to_an_alternative_index
    document = {
      "title" => "TITLE",
      "description" => "DESCRIPTION",
      "format" => "NAME OF FORMAT",
      "section" => "NAME OF SECTION",
      "subsection" => "NAME OF SUBSECTION",
      "link" => "/link",
      "indexable_content" => "TEXT",
      "boost_phrases" => "BOOST"
    }
    json = MultiJson.encode([document])

    stub_request(:post, "#{API}/alternative/documents").
      with(body: json).
      to_return(status: 200, body: '{"result":"OK"}')

    Rummageable.index(document, "/alternative")
  end

  def test_should_post_to_rummageable_host_determined_by_rummager_service_name
    document = {"title" => "TITLE"}
    stub_request(:post, "#{API}/documents")
    stub_request(:post, "#{Plek.current.find("whitehall-search")}/documents")
    with_rummager_service_name("whitehall-search") do
      Rummageable.index(document)
    end
    assert_not_requested(:post, "#{API}/documents")
    assert_requested(:post, "#{Plek.current.find("whitehall-search")}/documents")
  end
end
