# encoding: utf-8

require 'spec_helper'

describe UsersController do
  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }

  before { sign_in user }

  it "renders the new template" do
    get :new
    response.should render_template("new")
  end

  it "doesn’t show other user’s page" do
    get :edit, id: other_user.id
    response.should redirect_to(root_path)
  end

end
