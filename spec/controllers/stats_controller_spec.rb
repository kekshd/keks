# encoding: utf-8

require 'spec_helper'

describe StatsController do
  let(:q) { FactoryGirl.create(:question_with_answers) }
  let(:admin) { FactoryGirl.create(:admin) }

  render_views

  describe "#new" do
    def params(*args)
      d = {question_id: q.id, skipped: "false", correct: "true", selected_answers: [q.answers.sample], time_taken: 5}
      args.each { |a| d.merge!(a) }
      d
    end

    it "sets correct to false and answers to empty array when skipping" do
      post :new, params(skipped: "true")
      expect(q.stats.last.skipped).to eql true
      expect(q.stats.last.correct).to eql false
      expect(q.stats.last.selected_answers).to be_empty
    end

    it "rejects invalid answer ids" do
      post :new, params(selected_answers: [q.answers.sample, 9999123123123])
      expect(q.stats.last.selected_answers).not_to include(9999123123123)
    end

    it "stores time taken" do
      post :new, params
      expect(q.stats.last.time_taken).to eql 5
    end

    context "question with all false answers" do
      before do
        q.answers.each do |a|
          next unless a.correct?
          a.destroy
        end
        q.reload
      end

      it "can be answered correctly" do
        post :new, params(selected_answers: [])
        expect(q.stats.last.correct).to eql true
      end

      it "can be answered incorrectly" do
        post :new, params(correct: "false")
        expect(q.stats.last.correct).to eql false
      end
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
