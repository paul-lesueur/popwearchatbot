require "test_helper"

class DeadlinesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get deadlines_show_url
    assert_response :success
  end

  test "should get estimate_duration" do
    get deadlines_estimate_duration_url
    assert_response :success
  end
end
