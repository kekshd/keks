# encoding: utf-8

require 'spec_helper'

describe UsersController do
  let(:admin) { FactoryGirl.create(:admin) }
  let(:reviewer) { FactoryGirl.create(:reviewer) }
  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }

  render_views

  it "renders the new template" do
    get :new
    response.should render_template("new")
  end

  it "doesn’t show other user’s page" do
    sign_in user
    get :edit, id: other_user.id
    response.should redirect_to(root_path)
  end



  it "does not render user index for users" do
    sign_in user
    get :index
    response.should_not render_template :index
  end

  it "renders user index for admins" do
    sign_in admin
    get :index
    response.should render_template :index
  end


  it "admins may make someone reviewer" do
    sign_in admin
    put :toggle_reviewer, id: user.id
    response.should redirect_to(user_index_path)
    flash[:success].should_not be_nil
    flash[:error].should be_nil
    user.reload
    user.reviewer?.should == true
    user.admin?.should == false
  end


  it "admins may make someone admin" do
    sign_in admin
    put :toggle_admin, id: other_user.id
    response.should redirect_to(user_index_path)
    flash[:success].should_not be_nil
    flash[:error].should be_nil
    other_user.reload
    other_user.reviewer?.should == false
    other_user.admin?.should == true
  end
end
