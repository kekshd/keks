# encoding: utf-8

class UserMailer < ActionMailer::Base
  default from: "breunig@uni-hd.de"

  def password_reset(user)
    @user = user
    mail :to => user.mail, :subject => "Keks: Passwort zurücksetzen"
  end
end
