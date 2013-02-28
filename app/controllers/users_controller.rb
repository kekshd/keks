# encoding: utf-8

class UsersController < ApplicationController
  before_filter :signed_in_user,
                only: [:edit, :update, :destroy]
  before_filter :correct_user,   only: [:edit, :update]
  #~ before_filter :admin_user,     only: :destroy


  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Du bist jetzt angemeldet. Viel Spaß!"
      redirect_to :root
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Nutzerdaten aktualisiert"
      sign_in @user
      redirect_to @user
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
