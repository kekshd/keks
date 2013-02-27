require 'test_helper'

class MainControllerTest < ActionController::TestCase
  test "should get overview" do
    get :overview
    assert_response :success
  end

  test "should get hitme" do
    get :hitme
    assert_response :success
  end

  test "should get help" do
    get :help
    assert_response :success
  end

end
