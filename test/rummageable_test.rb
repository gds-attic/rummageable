require "minitest/autorun"
require "webmock/minitest"
require "rummageable"
ENV["RACK_ENV"] = "test"

class RummageableTest < MiniTest::Unit::TestCase

  def test_should_index_a_single_document_by_posting_it_as_json
    document = {
      "title" => "TITLE",
      "description" => "DESCRIPTION",
      "format" => "NAME OF FORMAT",
      "link" => "/link",
      "indexable_content" => "TEXT",
      "additional_links" => [
        {"title" => "LINK1", "link" => "/link1"},
        {"title" => "LINK2", "link" => "/link2"},
      ]
    }
    json = JSON.dump([document])

    stub_request(:post, "http://search.test.gov.uk/documents").
      with(body: json).
      to_return(status: 200, body: '{"status":"OK"}')

    Rummageable.index(document)
  end

  def test_should_index_multiple_documents_by_posting_them_as_json
    documents = [
      {"title" => "DOC1"},
      {"title" => "DOC2"}
    ]
    json = JSON.dump(documents)

    stub_request(:post, "http://search.test.gov.uk/documents").
      with(body: json).
      to_return(status: 200, body: '{"status":"OK"}')

    Rummageable.index(documents)
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

  def test_should_raise_an_exception_if_a_document_has_unrecognised_nested_keys
    document = {
      "additional_links" => [
        {"foo" => "bar"}
      ]
    }
    assert_raises Rummageable::InvalidDocument do
      Rummageable.index(document)
    end
  end

  def test_should_delete_a_document_by_its_link
    link = "http://example.com/foo"

    stub_request(:delete, "http://search.test.gov.uk/documents/http%3A%2F%2Fexample.com%2Ffoo").
      to_return(status: 200, body: '{"status":"OK"}')

    Rummageable.delete(link)
  end

end
