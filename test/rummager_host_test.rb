require 'test_helper'

class RummagerHostTest < MiniTest::Unit::TestCase
  def test_should_defer_to_plek_for_the_location_of_the_rummager_host
    assert_equal Plek.current.find("search"), Rummageable.rummager_host
  end

  def test_should_allow_the_rummager_host_to_be_set_manually_so_that_we_can_connect_to_rummager_running_at_arbitrary_locations
    Rummageable.rummager_host = "http://example.com"
    assert_equal "http://example.com", Rummageable.rummager_host
    ensure
      Rummageable.rummager_host = nil
  end
end
