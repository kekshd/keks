# encoding: utf-8

require 'spec_helper'

describe "stat time taken reporting" do
  let!(:categories) { FactoryGirl.create(:category_with_questions) }

  subject { page }

  describe "on hitme pages", :js => true do
    def save_answer_button
      all('.answer-submit a.button.big[data-action="save"]').last
    end

    it "stores correct time taken for first question" do
      category_select
      # time taken is now running
      sleep 4
      save_answer_button.click
      wait_for_non_dom_ajax
      expect(Stat.last.time_taken).to be_within(3.9).of(4.1)
    end

    it "doesn’t accumulate the time for the 2nd question" do
      category_select
      # time taken is now running
      sleep 4
      save_answer_button.click
      sleep 2
      wait_for_non_dom_ajax
      expect(Stat.last.time_taken).to be_within(1.9).of(2.1)
    end
  end
end
