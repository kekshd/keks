# encoding: utf-8

require 'spec_helper'

describe AnswersController do
  let(:admin) { FactoryGirl.create(:admin) }
  let(:question) { FactoryGirl.create(:question_with_answers) }

  render_views

  before(:each) do
    sign_in admin
  end

  it "redirects to question list for non-existing question" do
    get :edit, question_id: 9912939123123123436345, id: 5
    expect(response).to redirect_to questions_path
  end

  describe "#new" do
    it "renders new template" do
      get :new, question_id: question.id
      expect(response).to render_template("new")
    end

    it "inserts auto-generated ident" do
      get :new, question_id: question.id
      expect(response.body).to have_selector("#answer_ident[value]")
    end
  end

  describe "#edit" do
    it "renders edit template" do
      get :edit, question_id: question.id, id: question.answers.sample.id
      expect(response).to render_template("edit")
    end
  end

  describe "#create" do
    before(:each) do
      post :create, question_id: question.id, answer: {
        correct: false, text: "le work ✓", ident: "le id" }
      question.reload
      @answ = question.answers.find { |a| a.ident == "le id" }
    end

    it "updates question#content_changed_at" do
      question.reload
      expect(question.content_changed_at).to be > Time.now - 60
    end

    it "reports success" do
      expect(flash[:success]).not_to be_nil
    end

    it "returns to question" do
      expect(response).to redirect_to question_path(question.id)
    end
  end

  describe "#create with existing ident" do
    before(:each) do
      post :create, question_id: question.id, answer: {
        correct: false, text: "b0rk", ident: question.answers.first.ident }
      question.reload
    end

    it "renders new template again" do
      expect(response).to render_template(:new)
    end

    it "shows an error" do
      expect(response.body).to have_selector(".field_with_errors")
    end
  end

  describe "#update" do
    before(:each) do
      @answ = question.answers.sample
      post :update, question_id: question.id, id: @answ.id, answer: {
        correct: false, text: "le work ✓" }
    end

    it "updates answer in DB" do
      @answ.reload
      expect(@answ.text).to eql("le work ✓")
      expect(@answ.correct).to eql(false)
    end

    it "reports success" do
      expect(flash[:success]).not_to be_nil
    end

    it "returns to question" do
      expect(response).to redirect_to question_path(question.id)
    end

    it "updates question#content_changed_at" do
      question.reload
      expect(question.content_changed_at).to be > Time.now - 60
    end
  end

  describe "#update with existing ident" do
    before(:each) do
      answers = question.answers.sample(2)
      @answ = answers.first
      post :update, question_id: question.id, id: @answ.id, answer: {
        correct: false, text: "le work ✓", ident: answers.last.ident }
    end

    it "renders edit template again" do
      expect(response).to render_template(:edit)
    end

    it "shows an error" do
      expect(response.body).to have_selector(".field_with_errors")
    end
  end

  describe "#destroy" do
    it "removes answer from DB" do
      answ = question.answers.sample
      expect {
        delete :destroy, question_id: question.id, id: answ.id
      }.to change(Answer, :count)
      expect(flash[:success]).not_to be_nil
    end

    it "updates question#content_changed_at" do
      answ = question.answers.sample
      delete :destroy, question_id: question.id, id: answ.id
      question.reload
      expect(question.content_changed_at).to be > Time.now - 60
    end
  end
end
