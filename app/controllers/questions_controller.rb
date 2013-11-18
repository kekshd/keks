# encoding: utf-8

class QuestionsController < ApplicationController
  before_filter :require_admin, :except => [:star, :unstar, :perma]
  before_filter :signed_in_user, :only => [:star, :unstar]
  before_filter :find_question, except: [:create, :overwrite_reviews, :show, :new, :index, :single_parent_select, :search]

  def copy
    render partial: 'copy'
  end

  def copy_to
    def abort(msg)
      flash[:error] = msg
      redirect_to @question
    end

    ident = params[:ident].strip rescue ""
    if ident.blank?
      return abort("Kein Ident angegeben, daher kann die Frage nicht kopiert werden.")
    end

    if Question.where(ident: ident).any?
      return abort("Der angegebene Ident „#{ident}“ wird bereits verwendet. Kopieren fehlgeschlagen.")
    end

    new_question = @question.dup
    new_question.ident = ident
    new_question.released = false

    if new_question.save
      flash[:success] = "Frage kopiert. Du musst die Frage erst freigeben, bevor sie den Studis angezeigt wird."
    else
      return abort("Ein interner Fehler ist aufgetreten und die Frage konnte nicht kopiert werden. Details in den Logs.")
    end

    copy_assoc_objects(new_question)

    redirect_to question_path(new_question)
  end

  def star
    expires_now

    return render(json: "keine Frage") if !@question
    begin
      current_user.starred << @question
    rescue; end unless current_user.starred.include?(@question)
    render :json => current_user.starred.include?(@question)
  end

  def unstar
    expires_now

    return render(json: false) if !@question
    current_user.starred.delete(@question)
    render :json => current_user.starred.include?(@question)
  end

  def index
    ActiveRecord::lax_includes do
      if params[:category_id] && params[:category_id].to_i >= 0
        @questions = Question.where(parent_type: Category, parent_id: params[:category_id]).includes(parent: :question).all
        return render partial: "index_table"
      elsif params[:category_id] == "-1"
        @questions = Question.where("parent_type = ? OR parent_id = ?", "Answer", nil).includes(parent: :question).all
        return render partial: "index_table"
      else
        @categories = Category.order(:title).all
        @categories.reject! { |c| c.questions.count == 0 }
        return render :index
      end
    end
  end

  def search
    @page = page = [params[:page].to_i, 1].max
    @search = Question.search do
      fulltext(params[:query]) do
        highlight :ident, :text, :answers, :reviews, :hints, :parent
        query_phrase_slop 2
        boost_fields ident: 2.0
        boost_fields text: 1.5
        boost_fields answers: 1.1
        phrase_slop 2
      end
      paginate page: page, per_page: 15
    end
    @questions = @search.results
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
  end

  def show
    @question = Question.includes(:reviews, answers: [:questions, :categories]).find(params[:id])
  end

  def perma
  end

  def toggle_release
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
    time = Time.now.strftime("%Y-%m-%d %H:%M")
    okay = true
    @question.reviews.each do |r|
      if r.okay?
        r.touch if r.question_updated_since?
      else
        r.okay = true
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
    begin
      p = params[:parent].split('_')
      p = (p[0] == "Category") ? Category.find(p[1]) : Answer.find(p[1])
    rescue
      flash[:error] = "Kein gültiges Elter-Element angegeben"
      return render 'edit'
    end
    @question.parent = p

    if @question.update_attributes(params[:question])
      flash[:success] = "Frage aktualisiert"
      redirect_to @question
    else
      render 'edit'
    end
  end

  def single_parent_select
    render partial: "form_single_parent_select"
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
    if @question.destroy
      flash[:success] = "Frage gelöscht"
    else
      flash[:error] = "Frage nicht gelöscht. Siehe Log für mehr Informationen."
    end
    redirect_to questions_path
  end

  private
  def find_question
    id = params[:question_id] ? params[:question_id] : params[:id]
    @question = Question.find(id)
  end

  # copies answers and hints from this question to the specified one if
  # enabled. The status is directly read from the post parameters.
  def copy_assoc_objects(question)
    objs = []
    objs += @question.answers if params[:copy_answers] == "1"
    objs += @question.hints if params[:copy_hints] == "1"

    all_ok = true
    objs.each do |o|
      new_obj = o.dup
      new_obj.question = question
      all_ok = false unless new_obj.save
    end

    unless all_ok
      flash[:warning] = "Nicht alle Antworten/Hinweise konnten kopiert werden. Details in den Logs."
    end
  end
end
