# encoding: utf-8

class QuestionsController < ApplicationController
  before_filter :require_admin


  def index
    @questions = Question.all
    logger.warn PP.pp(@questions, '')
  end

  def new
    @question = Question.new
  end

  def edit
    @question = Question.find(params[:id])
  end

  def show
    @question = Question.find(params[:id])
  end

  def update
    @question = Question.find(params[:id])
    if @question.update_attributes(params[:question])
      flash[:success] = "Frage aktualisiert"
      redirect_to @question
    else
      render 'edit'
    end
  end


  def create
    @question = Question.new(params[:question])

    p = params[:parent].split('_')
    p = (p[0] == "Category") ? Category.find(p[1]) : Answer.find(p[1])
    @question.parent = p

    if @question.save
      flash[:success] = "Frage gespeichert"
      redirect_to @question
    else
      render 'new'
    end
  end
end
