# encoding: utf-8

class UserMailer < ActionMailer::Base
  default from: "keks@uni-hd.de"

  def password_reset(user)
    @user = user
    mail :to => user.mail, :subject => "KeKs: Passwort zurücksetzen"
  end

  def feedback(text, name, addr)
    @text = text
    @name = name
    @mail = addr
    mail :to => "keks@uni-hd.de", :subject => "KeKs: Feedback", :from => @mail || "keks@uni-hd.de"
  end
end
