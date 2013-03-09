# encoding: utf-8

require 'spec_helper'

describe Question do
  it "can be saved" do
    FactoryGirl.build(:question).should be_valid
  end

  it "can’t be saved without text" do
    FactoryGirl.build(:question, :text => "").should_not be_valid
  end

  it "is complete with answers" do
    q = FactoryGirl.create(:question_parent_category)
    q.complete?.should be_true
    q.incomplete_reason.should be_empty
  end

  it "is incomplete without answers" do
    q = FactoryGirl.create(:question_no_answers)
    q.complete?.should be_false
    q.incomplete_reason.should_not be_empty
  end
end
