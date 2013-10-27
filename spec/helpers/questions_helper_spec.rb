# encoding: utf-8

require "spec_helper"

describe QuestionsHelper do
  describe "#link_to_parent" do
    it "links to parent category" do
      q = FactoryGirl.build(:question_parent_category)
      expect(helper.link_to_parent(q)).to include(q.parent.link_text, category_path(q.parent))
    end

    it "links to parent answer’s question" do
      q = FactoryGirl.build(:question_parent_answer)
      a = q.parent
      link = question_path(a.question)
      expect(helper.link_to_parent(q)).to include(q.parent.link_text, link)
    end
  end

  describe "#get_question_stat_counts" do
    it "returns stats for all questions when none given" do
      r = helper.get_question_stat_counts
      expect(r[:all]).to eql({})
      expect(r[:skip]).to eql({})
      expect(r[:correct]).to eql({})
    end
  end
end
