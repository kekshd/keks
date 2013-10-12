# encoding: utf-8

require 'spec_helper'

describe Stat do
  let(:stat) { FactoryGirl.build(:stat) }
  let(:stat_skipped) { FactoryGirl.build(:stat_skipped) }

  it "can be saved" do
    expect(stat).to be_valid
  end

  it "detects skipped stats" do
    expect(stat_skipped.correct?).to be_false
    expect(stat_skipped.wrong?).to be_false
  end

  it "detects if no user is known" do
    expect(stat_skipped.anonymous?).to be_false
  end

  it "serializes its answers" do
    expect(stat.selected_answers).to be_a(Array)
    expect(stat.selected_answers.first).to be_a(Fixnum)
  end
end
