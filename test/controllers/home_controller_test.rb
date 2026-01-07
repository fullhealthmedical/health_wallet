require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
  end

  test "displays app name" do
    get root_url
    assert_match "Health Wallet", response.body
  end
end
