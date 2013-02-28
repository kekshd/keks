class QuestionsController < ApplicationController
  before_filter :require_admin


  def new
    @question = Question.new
  end

  def create
    require "pp"

    if !params['category'] || !params['category']['answers']  || params['category']['answers'].size < 1
      flash.now['error'] = 'Mindestens eine Antwort notwendig.'
      return render 'new'
    end

    answ = params['category']['answers'].map do |a|
      Answer.new(a)
    end
    params['category'].delete('answers')

    @question = Question.new(params[:category])


    if @question.save
      flash[:success] = "Frage gespeichert"
      redirect_to questions_path
    else
      render 'new'
    end
  end
end
