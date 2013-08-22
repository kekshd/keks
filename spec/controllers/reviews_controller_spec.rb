# encoding: utf-8

require 'spec_helper'

describe ReviewsController do
  let(:admin) { FactoryGirl.create(:admin) }
  let(:reviewer) { FactoryGirl.create(:reviewer) }

  render_views

  it "it chooses the correct template to render (Admins)" do
    sign_in admin
    get :need_attention
    response.should render_template :need_attention
  end

  it "it chooses the correct template to render (Reviewer)" do
    sign_in reviewer
    get :need_attention
    response.should render_template :need_attention
  end

  it "it doesn’t render the page for non-signed in users" do
    get :need_attention
    response.should_not render_template :need_attention
  end

  it "shows the correct page parts for admins" do
    sign_in admin
    get :need_attention
    response.should render_template :need_attention
    response.body.should have_text "Lieber Admin"
  end

  it "renders the need attention template for reviewers" do
    sign_in reviewer
    get :need_attention
    response.should render_template :need_attention
    response.body.should have_content "Lieber Reviewer"
    response.body.should_not have_content "Lieber Admin"
  end
end
