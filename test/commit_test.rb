require 'test_helper'

class CommitTest < MiniTest::Unit::TestCase
  def commit_url
    [rummager_url, index_name, 'commit'].join('/')
  end

  def test_commit_should_post_to_rummager
    stub_request(:post, commit_url).to_return(status(200))
    index = Rummageable::Index.new(rummager_url, index_name)
    index.commit
    assert_requested :post, commit_url, body: json_for({})
  end
end
