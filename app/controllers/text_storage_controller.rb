# encoding: utf-8

class TextStorageController < ApplicationController
  before_filter :require_admin

  def update
    @message = TextStorage.find(params[:id])

    if @message.update_attributes(params[:text_storage])
      flash[:success] = "Mitteilung aktualisiert"
      redirect_to :back
    else
      redirect_to :back
    end
  end
end
