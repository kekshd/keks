require 'test_helper'

class LatexControllerTest < ActionController::TestCase
  test "should get render" do
    get :render
    assert_response :success
  end

end
