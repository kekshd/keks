# encoding: utf-8

require 'spec_helper'

describe TextStorage do

  it "returns vanilla text for non existing" do
    expect(TextStorage.get("does_not_exist")).to include("(does_not_exist)")
  end

  it "can be saved" do
    expect(FactoryGirl.build(:text_storage)).to be_valid
    expect(FactoryGirl.build(:text_storage_empty)).to be_valid
  end

  it "returns saved text" do
    entry = FactoryGirl.create(:text_storage)
    expect(TextStorage.get(entry.ident)).to eql(entry.value)
  end
end
