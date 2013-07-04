require 'test_helper'

class CommitTest < MiniTest::Unit::TestCase
  def test_should_commit_to_rummmageable_host
    stub_request(:post, "#{rummager_url}/commit").
      to_return(status: 200, body: '{"result":"OK"}')

    Rummageable.commit
  end

  def test_should_allow_committing_an_alternative_index
    stub_request(:post, "#{rummager_url}/alternative/commit").
      to_return(status: 200, body: '{"result":"OK"}')

    Rummageable.commit '/alternative'
  end
end
