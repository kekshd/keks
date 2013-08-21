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
    # not using be_empty here so that the test directly shows the reason
    # why a question is not considered complete
    q.incomplete_reason.should eq ""
    q.complete?.should be_true
  end

  it "is incomplete without answers" do
    q = FactoryGirl.create(:question_no_answers)
    q.incomplete_reason.should_not eq ""
    q.complete?.should be_false
  end
end
