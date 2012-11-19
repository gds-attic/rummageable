require "minitest/autorun"
require "webmock/minitest"
require "rummageable"
ENV["RACK_ENV"] = "test"

class RummageableTest < MiniTest::Unit::TestCase
  API = Plek.current.find("search")

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
      "boost_phrases" => "BOOST",
      "additional_links" => [
        {"title" => "LINK1", "link" => "/link1"},
        {"title" => "LINK2", "link" => "/link2"},
      ]
    }
    json = JSON.dump([document])

    stub_request(:post, "#{API}/documents").
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

    stub_request(:post, "#{API}/documents").
      with(body: json).
      to_return(status: 200, body: '{"status":"OK"}')

    Rummageable.index(documents)
  end

  def test_should_send_documents_in_batches_of_20
    documents = 21.times.map { |i| {"title" => "DOC#{i}"} }

    stub_request(:post, "#{API}/documents").
      to_return(status: 200, body: '{"status":"OK"}')

    Rummageable.index(documents)
    assert_requested :post, "#{API}/documents", body: JSON.dump(documents[0, 20])
    assert_requested :post, "#{API}/documents", body: JSON.dump(documents[20, 1])
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

  def test_allows_indexing_to_an_alternative_index
    document = {
      "title" => "TITLE",
      "description" => "DESCRIPTION",
      "format" => "NAME OF FORMAT",
      "section" => "NAME OF SECTION",
      "subsection" => "NAME OF SUBSECTION",
      "link" => "/link",
      "indexable_content" => "TEXT",
      "boost_phrases" => "BOOST",
      "additional_links" => [
        {"title" => "LINK1", "link" => "/link1"},
        {"title" => "LINK2", "link" => "/link2"},
      ]
    }
    json = JSON.dump([document])

    stub_request(:post, "#{API}/alternative/documents").
      with(body: json).
      to_return(status: 200, body: '{"status":"OK"}')

    Rummageable.index(document, "/alternative")
  end

  def test_should_post_to_rummageable_host_determined_by_rummager_service_name
    document = {"title" => "TITLE"}
    stub_request(:post, "#{API}/documents")
    stub_request(:post, "http://whitehall-search.test.gov.uk/documents")
    with_rummager_service_name("whitehall-search") do
      Rummageable.index(document)
    end
    assert_not_requested(:post, "#{API}/documents")
    assert_requested(:post, "http://whitehall-search.test.gov.uk/documents")
  end

  def test_should_delete_a_document_by_its_link
    link = "http://example.com/foo"

    stub_request(:delete, "#{API}/documents/http:%2F%2Fexample.com%2Ffoo").
      to_return(status: 200, body: '{"status":"OK"}')

    Rummageable.delete(link)
  end

  def test_should_allow_deletion_from_an_alternative_index
    link = "http://example.com/foo"

    stub_request(:delete, "#{API}/alternative/documents/http:%2F%2Fexample.com%2Ffoo").
      to_return(status: 200, body: '{"status":"OK"}')

    Rummageable.delete(link, '/alternative')
  end

  def test_should_allow_delete_all
    stub_request(:delete, "#{API}/documents/*").
      to_return(status: 200, body: '{"status":"OK"}')

    Rummageable.delete_all
  end

  def test_should_allow_delete_all_from_an_alternative_index
    stub_request(:delete, "#{API}/alternative/documents/*").
      to_return(status: 200, body: '{"status":"OK"}')

    Rummageable.delete_all('/alternative')
  end

  def test_should_post_amendments
    stub_request(:post, "#{API}/documents/%2Ffoobang").
      with(body: {"title" => "Cheese", "indexable_content" => "Blah"}).
      to_return(status: 200, body: '{"status":"OK"}')

    Rummageable.amend("/foobang", {"title" => "Cheese", "indexable_content" => "Blah"})
  end

  def test_should_reject_unknown_amendments
    stub_request(:post, "#{API}/documents/%2Ffoobang").
      to_return(status: 200, body: '{"status":"OK"}')

    assert_raises Rummageable::InvalidDocument do
      Rummageable.amend("/foobang", {"title" => "Cheese", "face" => "Blah"})
    end

    assert_not_requested :any, "#{API}/documents/%2Ffoobang"
  end

  def test_should_fail_amendments_with_symbols
    stub_request(:post, "#{API}/documents/%2Ffoobang").
      to_return(status: 200, body: '{"status":"OK"}')

    assert_raises Rummageable::InvalidDocument do
      Rummageable.amend("/foobang", {title: "Cheese"})
    end

    assert_not_requested :any, "#{API}/documents/%2Ffoobang"
  end

  def test_should_delete_to_rummageable_host_determined_by_rummager_service_name
    link = "http://example.com/foo"
    stub_request(:delete, "#{API}/documents/http:%2F%2Fexample.com%2Ffoo")
    stub_request(:delete, "http://whitehall-search.test.gov.uk/documents/http:%2F%2Fexample.com%2Ffoo")
    with_rummager_service_name("whitehall-search") do
      Rummageable.delete(link)
    end
    assert_not_requested(:delete, "#{API}/#{API}/documents/http:%2F%2Fexample.com%2Ffoo")
    assert_requested(:delete, "http://whitehall-search.test.gov.uk/documents/http:%2F%2Fexample.com%2Ffoo")
  end

  def test_should_defer_to_plek_for_the_location_of_the_rummager_host
    assert_equal Plek.current.find("search"), Rummageable.rummager_host
  end

  def test_should_allow_the_rummager_host_to_be_set_manually_so_that_we_can_connect_to_rummager_running_at_arbitrary_locations
    Rummageable.rummager_host = "http://example.com"
    assert_equal "http://example.com", Rummageable.rummager_host
    ensure
      Rummageable.rummager_host = nil
  end

  def test_should_commit_to_rummmageable_host
    stub_request(:post, "#{API}/commit").
      to_return(status: 200, body: '{"result":"OK"}')

    Rummageable.commit
  end

  def test_should_allow_committing_an_alternative_index
    stub_request(:post, "#{API}/alternative/commit").
      to_return(status: 200, body: '{"result":"OK"}')

    Rummageable.commit '/alternative'
  end

  private

  def with_rummager_service_name(service_name)
    original_rummager_service_name = Rummageable.rummager_service_name
    Rummageable.rummager_service_name = "whitehall-search"
    yield
  ensure
    Rummageable.rummager_service_name = original_rummager_service_name
  end

end
