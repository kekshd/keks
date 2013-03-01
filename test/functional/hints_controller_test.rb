require 'test_helper'

class HintsControllerTest < ActionController::TestCase
  setup do
    @hint = hints(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:hints)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create hint" do
    assert_difference('Hint.count') do
      post :create, hint: { order: @hint.order, question_id: @hint.question_id, text: @hint.text }
    end

    assert_redirected_to hint_path(assigns(:hint))
  end

  test "should show hint" do
    get :show, id: @hint
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @hint
    assert_response :success
  end

  test "should update hint" do
    put :update, id: @hint, hint: { order: @hint.order, question_id: @hint.question_id, text: @hint.text }
    assert_redirected_to hint_path(assigns(:hint))
  end

  test "should destroy hint" do
    assert_difference('Hint.count', -1) do
      delete :destroy, id: @hint
    end

    assert_redirected_to hints_path
  end
end
