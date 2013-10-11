# encoding: utf-8

require 'spec_helper'

describe QuestionsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:admin) { FactoryGirl.create(:admin) }
  let(:reviewer) { FactoryGirl.create(:reviewer) }
  let(:question) { FactoryGirl.create(:question) }

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
end
