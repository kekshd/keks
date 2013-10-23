# encoding: utf-8

class AnswersController < ApplicationController
  before_filter :require_admin
  before_filter :get_question

  def new
    @answer = Answer.new
    @answer.ident ||= gen_answer_ident(@question)
  end

  def edit
    @answer = Answer.find(params[:id])
  end

  def update
    @answer = Answer.find(params[:id])
    if @answer.update_attributes(params[:answer])
      flash[:success] = "Antwort aktualisiert"
      redirect_to @question
    else
      render 'edit'
    end
  end


  def create
    @answer = Answer.new(params[:answer])
    @answer.question = @question

    if @answer.save
      flash[:success] = "Antwort gespeichert"
      redirect_to @question
    else
      render 'new'
    end
  end

  def destroy
    @answer = Answer.find(params[:id])
    if @answer.destroy
      flash[:success] = "Antwort gelöscht"
    else
      flash[:error] = "Antwort konnte nicht gelöscht werden. Vermutlich steht in den Logs mehr."
    end
    redirect_to @question
  end

  private

  def get_question
    @question = Question.find(params[:question_id]) rescue nil
    unless @question
      flash[:warning] = "Frage mit dieser ID nicht gefunden."
      redirect_to questions_path
    end
  end

  def gen_answer_ident(question)
    idents = question.answers.map { |a| a.ident.to_s }
    id = question.answers.size + 1
    5.times do
      break unless idents.include?(id.to_s)
      id += 1
    end
    id.to_s
  end
end
