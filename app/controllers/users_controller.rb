# encoding: utf-8

class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:edit, :update, :destroy, :enroll, :starred]
  before_filter :correct_user,  only: [:edit, :update, :enroll, :starred]

  def starred
  end

  def new
    @user = User.new
  end

  def create
    nick = params[:user][:nick]
    params[:user].delete(:nick)
    @user = User.new(params[:user])
    @user.nick = nick
    if @user.save
      sign_in @user
      flash[:success] = "Du bist jetzt angemeldet. Diese Seite ist Deine Profilseite. Hier kannst Du auch einen Einschreibeschlüssel eintragen, wenn Dir einer mitgeteilt wurde."
      redirect_to edit_user_path(@user)
    else
      render 'new'
    end
  end

  def edit
  end

  def enroll
    key = (params[:enrollment_key] || '').gsub(/[^a-z0-9]/i, "")
    if !key
      flash[:error] = "Kein Einschreibeschlüssel angegeben."
      render 'edit'
    elsif @user.enrollment_keys && @user.enrollment_keys.split.include?(key)
      flash[:warning] = "In diese Veranstaltung bist Du schon eingeschrieben."
      redirect_to edit_user_path(@user)
    elsif !EnrollmentKeys.names.include?(key)
      flash[:error] = "Dieser Einschreibeschlüssel ist unbekannt. Die Groß-/Kleinschreibung zählt."
      render 'edit'
    else
      @user.enrollment_keys ||= ""
      @user.enrollment_keys += " #{key}"
      if @user.save
        flash[:success] = "Erfolgreich in #{key} eingeschrieben."
        sign_in @user
        redirect_to edit_user_path(@user)
      else
        flash[:error] = "Konnte Dich nicht in #{key} einschreiben. Bitte kontaktiere eine in der Hilfe aufgelistete Person."
        render 'edit'
      end
    end
  end

  def update
    @user.updating_password = params[:type] == 'pwchange'

    if @user.update_attributes(params[:user])
      flash[:success] = "Nutzerdaten aktualisiert"
      sign_in @user
      redirect_to edit_user_path(@user)
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "Deine Daten wurden gelöscht. Beehre uns bald wieder."
    redirect_to users_url
  end

  private

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end
end
