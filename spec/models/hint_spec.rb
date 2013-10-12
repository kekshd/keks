# encoding: utf-8

require 'spec_helper'

describe Hint do
  it "can be saved" do
    expect(FactoryGirl.build(:hint)).to be_valid
  end

  it "renders dot" do
    h = FactoryGirl.build(:hint)
    expect(h.dot).to include(h.dot_id, h.dot_text)
  end
end
