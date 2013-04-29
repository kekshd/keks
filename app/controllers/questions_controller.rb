# encoding: utf-8

class QuestionsController < ApplicationController
  before_filter :require_admin, :except => [:star, :unstar, :perma]
  before_filter :signed_in_user, :only => [:star, :unstar]

  def star
    @question = Question.find(params[:id])
    return render :json => "keine Frage" if !@question
    begin
      current_user.starred << @question
    rescue; end unless current_user.starred.include?(@question)
    render :json => current_user.starred.include?(@question)
  end

  def unstar
    @question = Question.find(params[:id])
    return render :json => false if !@question
    #~ begin
      current_user.starred.delete(@question)
    #~ rescue; end
    render :json => current_user.starred.include?(@question)
  end

  def index
    @questions = Question.all
  end

  def new
    @question = Question.new

    if params['parent']
      s = params['parent'].split('_', 2)

      @answer = Answer.find(s.last.to_i) if s.first == "Answer"
      @question.parent = @answer if @answer

      @category = Category.find(s.last.to_i) if s.first == "Category"
      @question.parent = @category if @category
    end
  end

  def edit
    @question = Question.find(params[:id])
  end

  def show
    @question = Question.find(params[:id])
  end

  def perma
    @question = Question.find(params[:id])
  end

  def update
    @question = Question.find(params[:id])

    p = params[:parent].split('_')
    p = (p[0] == "Category") ? Category.find(p[1]) : Answer.find(p[1])
    @question.parent = p

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

  def destroy
    @question = Question.find(params[:id])
    if @question.destroy
      flash[:success] = "Frage gelöscht"
    else
      flash[:error] = "Frage nicht gelöscht. Siehe Log für mehr Informationen."
    end
    redirect_to questions_path
  end


  def json
    @question = Question.find(params[:id])
    hints = []
    @question.hints.each do |h|
      @hint = h
      hints << render_to_string(partial: '/hints/render.html.erb')
    end

    render json: {
      'hints' => hints,
      'html' => render_to_string(partial: 'render.html.erb')
    }
  end
end
