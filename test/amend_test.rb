require 'test_helper'

class AmendTest < MiniTest::Unit::TestCase
  def test_should_post_amendments
    stub_request(:post, "#{rummager_url}/documents/%2Ffoobang").
      with(body: {"title" => "Cheese", "indexable_content" => "Blah"}).
      to_return(status: 200, body: '{"result":"OK"}')

    Rummageable.amend("/foobang", {"title" => "Cheese", "indexable_content" => "Blah"})
  end

  def test_should_reject_unknown_amendments
    stub_request(:post, "#{rummager_url}/documents/%2Ffoobang").
      to_return(status: 200, body: '{"result":"OK"}')

    assert_raises Rummageable::InvalidDocument do
      Rummageable.amend("/foobang", {"title" => "Cheese", "face" => "Blah"})
    end

    assert_not_requested :any, "#{rummager_url}/documents/%2Ffoobang"
  end

  def test_should_fail_amendments_with_symbols
    stub_request(:post, "#{rummager_url}/documents/%2Ffoobang").
      to_return(status: 200, body: '{"result":"OK"}')

    assert_raises Rummageable::InvalidDocument do
      Rummageable.amend("/foobang", {title: "Cheese"})
    end

    assert_not_requested :any, "#{rummager_url}/documents/%2Ffoobang"
  end
end
