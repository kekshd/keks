# encoding: utf-8

require 'spec_helper'

describe HintsController do
  let(:admin) { FactoryGirl.create(:admin) }
  let(:question) { FactoryGirl.create(:question_with_answers) }

  render_views

  before(:each) do
    sign_in admin
  end

  describe "#new" do
    it "renders new template" do
      get :new, question_id: question.id
      expect(response).to render_template("new")
    end
  end

  describe "#edit" do
    it "renders edit template" do
      get :edit, question_id: question.id, id: question.hints.sample.id
      expect(response).to render_template("edit")
    end

    it "redirects to question list for non-existing question" do
      get :edit, question_id: 9912939123123123436345, id: 5
      expect(response).to redirect_to questions_path
    end

    it "redirects to question for non-existing hint" do
      get :edit, question_id: question.id, id: 123829349283429384123912
      expect(response).to redirect_to question
    end
  end

  describe "#create" do
    before(:each) do
      post :create, question_id: question.id, hint:
        { sort_hint: 9999, text: "le work ✓" }
      question.reload
      @hint = question.hints.find { |h| h.sort_hint == 9999 }
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

  describe "#create with errors" do
    before do
      post :create, question_id: question.id, hint:
        { sort_hint: "non numerical", text: "" }
    end

    it "renders new template again" do
      expect(response).to render_template("new")
    end

    it "reports errors" do
      expect(response.body).to have_selector(".field_with_errors")
    end
  end

  describe "#update" do
    before(:each) do
      @hint = question.hints.sample
      post :update, question_id: question.id, id: @hint.id, hint: {
        text: "le new text" }
    end

    it "updates hint in DB" do
      @hint.reload
      expect(@hint.text).to eql("le new text")
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

  describe "#update with errors" do
    before do
      @hint = question.hints.sample
      post :update, question_id: question.id, id: @hint.id, hint:
        { sort_hint: "non numerical", text: "" }
    end

    it "renders edit template again" do
      expect(response).to render_template("edit")
    end

    it "reports errors" do
      expect(response.body).to have_selector(".field_with_errors")
    end
  end

  describe "#destroy" do
    it "removes hint from DB" do
      hint = question.hints.sample
      expect {
        delete :destroy, question_id: question.id, id: hint.id
      }.to change(Hint, :count)
      expect(flash[:success]).not_to be_nil
    end

    it "updates question#content_changed_at" do
      hint = question.hints.sample
      delete :destroy, question_id: question.id, id: hint.id
      question.reload
      expect(question.content_changed_at).to be > Time.now - 60
    end
  end
end
