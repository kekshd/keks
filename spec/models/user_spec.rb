# encoding: utf-8

require 'spec_helper'

describe User do
  let(:user) { FactoryGirl.create(:user) }

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
    user.remember_token.should_not be nil
  end

  it "has a password digest" do
    user.password_digest.should_not be nil
    user.password_digest.should_not be_empty
  end

  it "sends password recovery mail" do
    user.send_password_reset
    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to include(user.mail)
    expect(mail.body.encoded).to include(user.password_reset_token)
    expect(mail.body.encoded).to include("/password_resets/") # i.e. url
  end
end
