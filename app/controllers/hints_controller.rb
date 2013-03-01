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
    @hint = Hint.find(params[:id])
  end

  def create
    @hint = Hint.new(params[:hint])
    @hint.question = @question

    if @hint.save
      flash[:success] = "Hiwneis gespeichert"
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
    @hint.destroy

    respond_to do |format|
      format.html { redirect_to hints_url }
      format.json { head :no_content }
    end
  end

  private

  def get_question
    @question = Question.find(params[:question_id])
    unless @question
      flash[:warning] = "Frage mit dieser ID nicht gefunden."
      redirec_to questions_path
    end
  end
end
