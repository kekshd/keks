# encoding: utf-8

require 'spec_helper'

describe ReviewsController do
  let(:admin) { FactoryGirl.create(:admin) }
  let(:reviewer) { FactoryGirl.create(:reviewer) }
  let(:question) { FactoryGirl.create(:question_with_many_good_reviews) }
  let(:review) { FactoryGirl.create(:review) }

  render_views

  it "chooses the correct template to render (Admins)" do
    sign_in admin
    get :need_attention
    response.should render_template :need_attention
  end

  it "chooses the correct template to render (Reviewer)" do
    sign_in reviewer
    get :need_attention
    response.should render_template :need_attention
  end

  it "doesn’t render the page for non-signed in users" do
    get :need_attention
    response.should_not render_template :need_attention
  end

  it "shows the correct page parts for admins" do
    sign_in admin
    get :need_attention
    response.should render_template :need_attention
    response.body.should have_text "Lieber Admin"
  end

  it "handles invalid question ids" do
    sign_in reviewer
    get :review, question_id: 1312312312312
    expect(response).to redirect_to :reviews
    expect(flash[:error]).not_to be_nil
  end

  it "shows all reviews for question" do
    sign_in reviewer
    get :review, question_id: question.id
    expect(response).to render_template :review
    question.reviews.each do |r|
      expect(response.body).to have_text r.comment
    end
  end

  it "renders the need attention template for reviewers" do
    sign_in reviewer
    get :need_attention
    response.should render_template :need_attention
    response.body.should have_content "Lieber Reviewer"
    response.body.should_not have_content "Lieber Admin"
  end

  describe "#messages" do
    it "shows message to reviewers" do
      t = FactoryGirl.create(:text_storage, ident: :review_admin_hints)
      sign_in reviewer
      get :messages
      response.body.should have_content t.value
      expect(response.body).not_to have_selector("form")
    end

    it "shows message an form to reviewers" do
      t = FactoryGirl.create(:text_storage, ident: :review_admin_hints)
      sign_in admin
      get :messages
      response.body.should have_content t.value
      expect(response.body).to have_selector("form")
      expect(response.body).to have_selector("textarea", text: t.value)
    end
  end

  describe "#save" do
    before(:each) do
      sign_in reviewer
      @r = FactoryGirl.create(:review, user: reviewer)
      @q = @r.question
    end

    it "updates review data" do
      post :save, question_id: @q.id, review: { comment: "test123" }
      expect(flash[:error]).to be_nil
      expect(response).to redirect_to question_review_path(@q.id)
      @r.reload
      expect(@r.comment).to eql("test123")
    end
  end

  describe "#find_next" do
    before(:each) do
      sign_in reviewer
    end

    it "handles invalid filters" do
      get :find_next, filter: "does not exist"
      expect(response).to redirect_to(reviews_path)
      expect(flash[:warning]).not_to be_nil
    end

    it "handles EOL" do
      get :find_next, filter: "enough_good_reviews"
      expect(response).to redirect_to(reviews_path)
      expect(flash[:notice]).not_to be_nil
    end

    it "prefers order on the next list" do
      get :find_next, filter: "all", next: "2,99"
      expect(response).to redirect_to(question_review_path(2, filter: "all", next: "99"))
    end

    it "ignores next items if invalid" do
      get :find_next, filter: "all", next: "99,88"
      expect(flash[:notice]).not_to be_nil
      # can’t use redirect_to because item is chosen at random
      expect(response.location).to include("admin/questions", "review")
    end

    it "ignores invalid broken next list" do
      get :find_next, filter: "all", next: "h4xx0r"
      expect(flash[:notice]).not_to be_nil
      # can’t use redirect_to because item is chosen at random
      expect(response.location).to include("admin/questions", "review")
    end

  end
end
