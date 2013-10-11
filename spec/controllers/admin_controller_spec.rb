# encoding: utf-8

require 'spec_helper'

describe AdminController do
  let(:user) { FactoryGirl.create(:user) }
  let(:admin) { FactoryGirl.create(:admin) }
  let(:reviewer) { FactoryGirl.create(:reviewer) }
  let!(:cats) { FactoryGirl.create(:category_with_questions) }

  render_views

  it "renders the export page for admins" do
    sign_in admin
    get :export
    response.should render_template :export
    response.body.should have_text "einsehbar"
  end

  it "renders the export page for reviewers" do
    sign_in reviewer
    get :export
    response.should render_template :export
    response.body.should have_text "einsehbar"
  end

  it "does not render export page for users" do
    sign_in user
    get :export
    response.should_not render_template :export
    response.body.should_not have_text "einsehbar"
  end

  it "generates dot and svgz tree representations" do
    get :tree, :format => :dot
    get :tree, :format => :svgz
  end
end
