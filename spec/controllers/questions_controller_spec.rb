# encoding: utf-8

require 'spec_helper'

describe QuestionsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:admin) { FactoryGirl.create(:admin) }
  let(:reviewer) { FactoryGirl.create(:reviewer) }
  let(:question) { FactoryGirl.create(:question) }
  let(:question_full) { FactoryGirl.create(:question_parent_category) }
  let!(:existing_question) { FactoryGirl.create(:question_with_answers) }
  let!(:existing_category) { FactoryGirl.create(:category) }

  render_views

  it "renders perma template for everyone" do
    get :perma, id: existing_question.id
    response.should render_template :perma
    response.body.should have_content existing_question.id
  end

  it "renders questions index for admins" do
    sign_in admin
    get :index
    response.should render_template :index
  end

  it "renders question details for admins" do
    sign_in admin
    get :show, id: existing_question.id
    response.should render_template :show
    response.body.should have_content existing_question.ident
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

  it "shows an error when toggling fails" do
    sign_in admin
    Question.stub(:find).and_return {
      question.stub(:save).and_return(false)
      question
    }
    put :toggle_release, question_id: question.id
    flash[:error].should_not be_nil
  end

  it "renders new template for admins" do
    sign_in admin
    get :new
    response.should render_template :new
  end

  it "renders new template for admins with category pre-selected" do
    sign_in admin
    get :new, parent: "Category_#{existing_category.id}"
    response.should render_template :new
    page = Capybara::Node::Simple.new(response.body)
    expect(page).to have_select('parent', selected: existing_category.ident)
  end

  it "renders new template for admins with answer pre-selected" do
    sign_in admin
    answ = existing_question.answers.first
    get :new, parent: "Answer_#{answ.id}"
    response.should render_template :new
    page = Capybara::Node::Simple.new(response.body)
    expect(page).to have_select('parent', selected: "#{existing_question.ident}/#{answ.ident}")
  end


  describe "#create" do
    before(:each) do
      sign_in admin
      @good_attr = {"utf8"=>"✓", "authenticity_token"=>"S1dVBhTWOqkzwOdTBRvVcLBUs4Gsr/9z+paAzT0p4X0=", "question"=>{"ident"=>"123", "text"=>"123", "difficulty"=>"5", "study_path"=>"1", "released"=>"0"}, "parent"=>"Category_#{existing_category.id}", "commit"=>"Frage anlegen"}
    end

    it "re-renders new template on failed save" do
      post :create
      assigns[:question].should be_new_record
      flash[:success].should be_nil
      response.should render_template :new
    end

    it "re-renders new template when missing required fields" do
      attr = @good_attr.dup
      attr["question"].delete("ident")
      post :create, attr
      assigns[:question].should be_new_record
      flash[:success].should be_nil
      response.should render_template :new
    end

    it "shows question on successful save" do
      post :create, @good_attr
      flash[:success].should_not be_nil
      response.should redirect_to question_path(Question.where(ident: "123").first)
    end
  end

  it "destroys question" do
    sign_in admin
    expect {
      expect {
        delete :destroy, id: existing_question.id
      }.to change(Question, :count)
    }.to change(Answer, :count)
    flash[:success].should_not be_nil
    response.should redirect_to questions_path
  end

  it "shows error when destroying fails" do
    sign_in admin
    Question.stub(:find).and_return {
      question.stub(:destroy).and_return(false)
      question
    }
    delete :destroy, id: question.id
    flash[:error].should_not be_nil
    response.should redirect_to questions_path
  end

  it "renders edit page" do
    sign_in admin
    get :edit, id: question_full.id
    expect(response).to render_template :edit
  end

  it "updates question" do
    sign_in admin
    new_ident = "new_test_ident"
    q = existing_question
    p = existing_category
    post :update, id: q.id, question: { ident: new_ident }, parent: "#{p.class}_#{p.id}"
    existing_question.reload

    expect(flash[:error]).to be_nil
    expect(flash[:success]).not_to be_nil
    expect(existing_question.ident).to eq(new_ident)
    expect(existing_question.parent_id).to eq(p.id)
    expect(existing_question.parent_type).to eq(p.class.to_s)

    response.should redirect_to existing_question
  end

  it "re-renders edit template on failed save" do
    sign_in admin
    new_ident = ""
    q = existing_question
    p = existing_category
    post :update, id: q.id, question: { ident: new_ident }, parent: "#{p.class}_#{p.id}"
    expect(response).to render_template :edit
  end

  it "re-renders edit template when given invalid parent" do
    sign_in admin
    new_ident = ""
    q = existing_question
    post :update, id: q.id, question: { ident: new_ident }
    expect(response).to render_template :edit
  end
end
