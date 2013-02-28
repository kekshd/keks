require 'test_helper'

class AdminControllerTest < ActionController::TestCase
  test "should get add_category" do
    get :add_category
    assert_response :success
  end

  test "should get add_question" do
    get :add_question
    assert_response :success
  end

  test "should get add_links" do
    get :add_links
    assert_response :success
  end

end
