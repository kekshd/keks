# encoding: utf-8

require 'spec_helper'

describe PasswordResetsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:user_no_mail) { FactoryGirl.create(:user, mail: "") }
  let(:user_valid_token) do
    FactoryGirl.create(:user,
      password_reset_token: "derp",
      password_reset_sent_at: Time.now - 30)
  end
  let(:user_expired_token) do
    FactoryGirl.create(:user,
      password_reset_token: "derp",
      password_reset_sent_at: Time.now - 10.hours)
  end

  describe "#create" do
    it "fails when user no mail address given" do
      post :create, mail: user_no_mail.mail
      expect(flash[:error]).not_to be_nil
    end

    it "fails when given unknown mail address" do
      post :create, mail: "does_not_exist@example.com"
      expect(flash[:error]).not_to be_nil
    end

    it "renders new template on failure" do
      post :create, mail: "does_not_exist@example.com"
      expect(response).to render_template(:new)
    end

    it "redirects to root if mail has been sent" do
      post :create, mail: user.mail
      expect(response).to redirect_to(root_path)
    end

    it "sends password mail if given valid address" do
      expect {
        post :create, mail: user.mail
      }.to change { ActionMailer::Base.deliveries.size }.by(1)
      mail = ActionMailer::Base.deliveries.last
    end

    it "sends mail to the given address" do
      post :create, mail: user.mail
      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to include(user.mail)
    end

    it "sends includes a reset link in the mail" do
      post :create, mail: user.mail
      mail = ActionMailer::Base.deliveries.last
      user.reload
      reset_link = edit_password_reset_path(user.password_reset_token)
      expect(mail.body.encoded).to include(reset_link)
    end
  end

  describe "#edit" do
    it "renders password reset template" do
      get :edit, id: user_valid_token.password_reset_token
      expect(response).to render_template(:edit)
    end

    it "redirects to reset password page when given invalid token" do
      get :edit, id: user_valid_token.password_reset_token + "fake"
      expect(response).to redirect_to(new_password_reset_path)
    end
  end

  describe "#update" do
    def upd(user, pass, pass_confirm)
      post :update, id: user.password_reset_token,
        user: { password: pass, password_confirmation: pass_confirm }
      user.reload
    end

    it "doesn’t update on expired links" do
      u = user_expired_token
      expect {
        upd(u, "a", "a")
      }.not_to change { u.password_digest.to_s }
    end

    it "updates password on valid token" do
      u = user_valid_token
      expect {
        upd(u, "a", "a")
      }.to change { u.password_digest.to_s }
    end

    it "redirects to signin on change" do
      upd(user_valid_token, "a", "a")
      expect(response).to redirect_to(signin_path)
    end

    it "re-renders edit template when passwords do not match" do
      u = user_valid_token
      expect {
        upd(u, "a", "b")
      }.not_to change { u.password_digest.to_s }
      expect(response).to render_template(:edit)
    end
  end
end
