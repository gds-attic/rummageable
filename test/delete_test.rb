require 'test_helper'

class DeleteTest < MiniTest::Unit::TestCase
  def test_should_delete_a_document_by_its_link
    link = "http://example.com/foo"

    stub_request(:delete, "#{rummager_url}/documents/http:%2F%2Fexample.com%2Ffoo").
      to_return(status: 200, body: '{"result":"OK"}')

    Rummageable.delete(link)
  end

  def test_should_allow_deletion_from_an_alternative_index
    link = "http://example.com/foo"

    stub_request(:delete, "#{rummager_url}/alternative/documents/http:%2F%2Fexample.com%2Ffoo").
      to_return(status: 200, body: '{"result":"OK"}')

    Rummageable.delete(link, '/alternative')
  end

  def test_should_allow_delete_all
    stub_request(:delete, "#{rummager_url}/documents?delete_all=1").
      to_return(status: 200, body: '{"result":"OK"}')

    Rummageable.delete_all
  end

  def test_should_allow_delete_all_from_an_alternative_index
    stub_request(:delete, "#{rummager_url}/alternative/documents?delete_all=1").
      to_return(status: 200, body: '{"result":"OK"}')

    Rummageable.delete_all('/alternative')
  end

  def test_should_delete_to_rummageable_host_determined_by_rummager_service_name
    link = "http://example.com/foo"
    stub_request(:delete, "#{rummager_url}/documents/http:%2F%2Fexample.com%2Ffoo")
    stub_request(:delete, "#{Plek.current.find("whitehall-search")}/documents/http:%2F%2Fexample.com%2Ffoo")
    with_whitehall_rummager_service { Rummageable.delete(link) }
    assert_not_requested(:delete, "#{rummager_url}/documents/http:%2F%2Fexample.com%2Ffoo")
    assert_requested(:delete, "#{Plek.current.find("whitehall-search")}/documents/http:%2F%2Fexample.com%2Ffoo")
  end
end
