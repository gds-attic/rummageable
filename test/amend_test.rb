require 'test_helper'

class AmendTest < MiniTest::Unit::TestCase
  def link
    '/path'
  end

  def test_should_post_amendments_to_a_document_by_its_link
    new_document = { 'title' => 'Cheese', 'indexable_content' => 'Blah' }
    stub_request(:post, link_url).with(body: new_document).to_return(status(200))
    index = Rummageable::Index.new(rummager_url, index_name)
    index.amend(link, { 'title' => 'Cheese', 'indexable_content' => 'Blah' })
    assert_requested :post, link_url, body: new_document
  end
end
