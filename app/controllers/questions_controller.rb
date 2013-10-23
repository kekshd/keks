# encoding: utf-8

class QuestionsController < ApplicationController
  before_filter :require_admin, :except => [:star, :unstar, :perma]
  before_filter :signed_in_user, :only => [:star, :unstar]

  def star
    expires_now

    @question = Question.find(params[:id])
    return render :json => "keine Frage" if !@question
    begin
      current_user.starred << @question
    rescue; end unless current_user.starred.include?(@question)
    render :json => current_user.starred.include?(@question)
  end

  def unstar
    expires_now

    @question = Question.find(params[:id])
    return render :json => false if !@question
    #~ begin
      current_user.starred.delete(@question)
    #~ rescue; end
    render :json => current_user.starred.include?(@question)
  end

  def index
    @questions = Question.includes(:parent, :answers, :reviews).all
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
    @question = Question.includes(:answers => [:questions, :categories]).find(params[:id])
  end

  def perma
    @question = Question.find(params[:id])
  end

  def toggle_release
    @question = Question.find(params[:question_id])
    if @question.toggle(:released) && @question.save
      flash[:success] = "Frage aktualisiert (Released: #{@question.released})"
      redirect_to :back
    else
      flash[:error] = "Konnte den Release-Status der Frage nicht umschalten."
      render 'edit'
    end
  end

  def overwrite_reviews
    @question = Question.includes(:reviews).find(params[:question_id])
    okay = true
    @question.reviews.each do |r|
      if r.okay?
        r.touch if r.question_updated_since?
      else
        r.okay = true
        time = Time.now.strftime("%Y-%m-%d %H:%M")
        r.comment = "#{time}: von #{current_user.nick} auf „okay“ gestellt\n\n#{r.comment}".strip
        okay = false unless r.save
      end
    end

    if okay
      flash[:success] = "Alle Reviews sollten jetzt „okay“ sein."
    else
      flash[:error] = "Es ist ein Fehler aufgetreten. Prüfe den Status der Reviews manuell."
    end

    redirect_to question_review_path(@question)
  end

  def update
    @question = Question.find(params[:id])

    begin
      logger.warn PP.pp(params, "")
      p = params[:parent].split('_')
    rescue
      flash[:error] = "Kein gültiges Elter-Element angegeben"
      return render 'edit'
    end

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

    begin
      p = params[:parent].split('_')
    rescue
      flash[:error] = "Kein gültiges Elter-Element angegeben"
      return render 'new'
    end

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
end
