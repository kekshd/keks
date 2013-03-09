# encoding: utf-8

require 'spec_helper'

describe User do
  it "can be saved" do
    FactoryGirl.build(:user).should be_valid
  end

  it "is invalid without nick" do
    FactoryGirl.build(:user, nick: nil).should_not be_valid
  end

  it "is invalid with non-existing study path" do
    FactoryGirl.build(:user, study_path: 324256457467452).should_not be_valid
  end

  it "is valid without mail" do
    FactoryGirl.build(:user, mail: nil).should be_valid
  end

  it "has a remember token" do
    FactoryGirl.create(:user).remember_token.should_not be nil
  end

  it "has a password digest" do
    FactoryGirl.create(:user).password_digest.should_not be nil
  end
end
