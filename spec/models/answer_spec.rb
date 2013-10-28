# encoding: utf-8

require 'spec_helper'

describe Answer do
  let(:answer) { FactoryGirl.create(:answer) }

  it "can be saved" do
    expect(answer).to be_valid
  end

  it "renders dot" do
    expect(answer.dot).to include(answer.dot_id, answer.id.to_s, answer.correct ? "green" : "red")
  end

  it "is released when its question is" do
    expect(answer.released?).to eql(answer.question.released?)
  end

  it "can be traced to root" do
    expect(answer.trace_to_root).to include(answer.id.to_s)
  end

  it "returns invalid ratio for matrix questions" do
    q = FactoryGirl.create(:question_matrix)
    expect(q.answers.first.check_ratio).to eql(-1)
  end

  it "returns valid ratio for normal questions" do
    s = FactoryGirl.create(:stat)
    a = Answer.find(s.selected_answers.first)
    # needs to be one because there is exactly one stat and this answer
    # was selected
    expect(a.check_ratio).to eql(1.0)
    others = Answer.where("id != ?", s.selected_answers.first)
    others.each do |o|
      expect(o.check_ratio).to eql(0.0)
    end
  end

  it "detects correct parent category" do
    q = FactoryGirl.create(:question_parent_category)
    a = FactoryGirl.create(:answer, question: q)

    expect(a.get_parent_category).to eql(q.parent)
  end

  it "prints link text" do
    expect(answer.link_text).to include(answer.id.to_s)
  end
end
