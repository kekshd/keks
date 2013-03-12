# encoding: utf-8

class UserMailer < ActionMailer::Base
  default from: "breunig@uni-hd.de"

  def password_reset(user)
    @user = user
    mail :to => user.mail, :subject => "KeKs: Passwort zurücksetzen"
  end

  def feedback(text, name, addr)
    @text = text
    @name = name
    @mail = addr
    mail :to => "breunig@uni-hd.de", :subject => "KeKs: Feedback"
  end
end
