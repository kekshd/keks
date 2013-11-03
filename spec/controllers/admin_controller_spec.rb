# encoding: utf-8

require 'spec_helper'

describe AdminController do
  let(:user) { FactoryGirl.create(:user) }
  let(:admin) { FactoryGirl.create(:admin) }
  let(:question) { FactoryGirl.create(:question_with_answers) }
  let(:reviewer) { FactoryGirl.create(:reviewer) }
  let!(:cats) { FactoryGirl.create(:question_parent_category_subs) }

  render_views

  describe "#export" do
    after do
      get :export
      expect(response).to render_template :export
      expect(response.body)to have_text "einsehbar"
      has_title
    end

    it "renders for admins" do
      sign_in admin
    end

    it "does for users" do
      sign_in user
    end

    it "does for not logged in people" do
    end
  end

  describe "#export_question" do
    it "renders question export partial" do
      sign_in admin
      get :export_question, question_id: question.id
      response.should render_template :export_question
    end
  end

  describe "#tree" do
    before { sign_in reviewer }

    it "generates plain dot" do
      get :tree, format: :dot
      expect(response.status).to eq(200)
      expect(response.body).to include("digraph")
    end

    it "generates svgz" do
      get :tree, format: :svgz
      expect(response.status).to eq(200)
      expect(response.body).not_to include("digraph")
    end
  end
end
