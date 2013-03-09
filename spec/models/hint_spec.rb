# encoding: utf-8

require 'spec_helper'

describe Hint do
  it "can be saved" do
    FactoryGirl.build(:hint).should be_valid
  end
end
