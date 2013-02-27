class SessionController < ApplicationController
  def create
    user = User.find_by_nick(params[:session][:nick])
    if user && user.authenticate(params[:session][:password])
      sign_in user
      redirect_back_or user
    else
      flash.now[:error] = 'Nutzername unbekannt oder Passwort ungültig.'
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end
end
