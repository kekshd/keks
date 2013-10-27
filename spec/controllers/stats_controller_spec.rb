# encoding: utf-8

require 'spec_helper'

describe StatsController do
  let(:q) { FactoryGirl.create(:question_with_answers) }
  let(:admin) { FactoryGirl.create(:admin) }

  render_views

  describe "#new" do
    it "sets correct to false and answers to empty array when skipping" do
      post :new, question_id: q, skipped: "true", correct: "true", selected_answers: [q.answers.sample]
      expect(q.stats.last.skipped).to eql true
      expect(q.stats.last.correct).to eql false
      expect(q.stats.last.selected_answers).to be_empty
    end

    it "rejects invalid answer ids" do
      post :new, question_id: q, skipped: "true", correct: "true", selected_answers: [q.answers.sample, 9999123123123]
      expect(q.stats.last.selected_answers).not_to include(9999123123123)
    end
  end

  describe "#report" do
    before { sign_in admin }

    it "returns to overview for unknown enrollment keys" do
      get :report, enrollment_key: "does not exist"
      expect(response).to redirect_to(admin_overview_path)
    end

    it "renders details for existing EnrollmentKey" do
      get :report, enrollment_key: EnrollmentKeys.names.first
      expect(response).to render_template(:report)
    end
  end

  describe "#category_report" do
    before { sign_in admin }
    before { FactoryGirl.create(:question_parent_category_subs) }

    it "renders details for root categories" do
      get :category_report
      expect(response).to render_template(:category_report)
    end
  end

  describe "#cactivity_report" do
    before { sign_in admin }

    it "renders activity stats" do
      get :activity_report
      expect(response).to render_template(:activity_report)
    end
  end
end
