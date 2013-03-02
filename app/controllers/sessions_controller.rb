# encoding: utf-8

class SessionsController < ApplicationController
  def create
    user = User.find_by_nick(params[:session][:nick])
    if user && user.authenticate(params[:session][:password])
      session[:remember_me] = params[:session][:remember_me] == "1"
      sign_in user
      redirect_back_or main_hitme_path
    else
      flash.now[:error] = 'Nutzername unbekannt oder Passwort ungültig.'
      render 'new'
      logger.warn user ? "correct user, wrong password" : "wrong user"
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end
end
