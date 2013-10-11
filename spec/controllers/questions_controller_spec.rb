# encoding: utf-8

require 'spec_helper'

describe QuestionsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:admin) { FactoryGirl.create(:admin) }
  let(:reviewer) { FactoryGirl.create(:reviewer) }
  let(:question) { FactoryGirl.create(:question) }
  let!(:existing_category) { FactoryGirl.create(:category) }

  render_views

  it "renders questions index for admins" do
    sign_in admin
    get :index
    response.should render_template :index
  end

  it "allows admins to toggle question release status" do
    sign_in admin
    request.env["HTTP_REFERER"] = question_path(question)
    put :toggle_release, question_id: question.id
    flash[:success].should_not be_nil
    flash[:error].should be_nil
    question.reload
    question.released?.should == false
    question.complete?.should == false
  end

  it "renders new template for admins" do
    sign_in admin
    get :new
    response.should render_template :new
  end

  it "should re-render new template on failed save" do
    sign_in admin
    post :create
    assigns[:question].should be_new_record
    flash[:success].should be_nil
    response.should render_template :new
  end

  it "should show question on successful save" do
    sign_in admin
    attr = {"utf8"=>"✓", "authenticity_token"=>"S1dVBhTWOqkzwOdTBRvVcLBUs4Gsr/9z+paAzT0p4X0=", "question"=>{"ident"=>"123", "text"=>"123", "difficulty"=>"5", "study_path"=>"1", "released"=>"0"}, "parent"=>"Category_#{existing_category.id}", "commit"=>"Frage anlegen"}
    post :create, attr
    flash[:success].should_not be_nil
    response.should redirect_to question_path(Question.where(ident: "123").first)
  end
end
