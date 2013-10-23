# encoding: utf-8

require "spec_helper"

describe "reviews/review.html.erb" do
  let(:admin) { FactoryGirl.create(:admin) }
  let(:question) { FactoryGirl.create(:question_with_many_good_reviews) }


  describe "overwrite link" do
    before(:each) do
      view.stub(:current_user).and_return(admin)
      question.parent = FactoryGirl.create(:category)
      question.save

      # fake old content_changed_at date this way to skip callbacks
      # that would overwrite the date change
      question.content_changed_at = Time.now - 1000000

      assign(:question, question)
    end

    it "isn’t shown when all reviews are good" do
      render
      expect(rendered).not_to have_selector("a[href*=overwrite_reviews]")
    end

    it "is shown when some reviews are not-okay" do
      r = question.reviews.sample
      r.okay = false
      r.save
      render
      expect(rendered).to have_selector("a[href*=overwrite_reviews]")
    end

    it "is shown when some reviews are outdated" do
      r = question.reviews.sample
      r.updated_at = Time.now - 10**10 # yeah, that’s pretty outdated
      r.save
      render
      expect(rendered).to have_selector("a[href*=overwrite_reviews]")
    end
  end
end
