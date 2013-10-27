# encoding: utf-8

class HintsController < ApplicationController
  before_filter :require_admin
  before_filter :get_question

  # GET /hints/new
  # GET /hints/new.json
  def new
    @hint = Hint.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @hint }
    end
  end

  # GET /hints/1/edit
  def edit
    @hint = Hint.find(params[:id]) rescue nil
    unless @hint
      flash[:warning] = "Unbekannter Hinweis. Hast Du evtl. einen alten Link angeklickt?"
      return redirect_to @question
    end
  end

  def create
    @hint = Hint.new(params[:hint])
    @hint.question = @question

    if @hint.save
      flash[:success] = "Hinweis gespeichert"
      redirect_to @question
    else
      render 'new'
    end
  end

  def update
    @hint = Hint.find(params[:id])
    if @hint.update_attributes(params[:hint])
      flash[:success] = "Hinweis aktualisiert"
      redirect_to @question
    else
      render 'edit'
    end
  end

  # DELETE /hints/1
  # DELETE /hints/1.json
  def destroy
    @hint = Hint.find(params[:id])
    if @hint.destroy
      flash[:success] = "Hinweis gelöscht"
    else
      flash[:error] = "Hinweis nicht gelöscht. Siehe Log für mehr Informationen."
    end
    redirect_to @question
  end
end
