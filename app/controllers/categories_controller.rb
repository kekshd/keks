# encoding: utf-8

class CategoriesController < ApplicationController
  before_filter :require_admin, :except => :questions

  def questions
    cat = Category.find(params[:id])

    cnt = params[:count].to_i
    return render :json => {error: "No count given"} if cnt <= 0 || cnt >= 100

    diff = params[:difficulty] ? params[:difficulty].split("_") : []
    diff = diff.map { |d| d.to_i == 0 ? nil : d.to_i}.compact
    diff.reject! { |d| !Difficulty.ids.include?(d) }
    return render :json => {error: "no difficulties given"} if diff.empty?

    sp = params[:study_path]
    if sp
      return render :json => {error: "invalid study path given"} if !StudyPath.ids.include?(sp.to_i)
      sp = [1, sp]
    else
      sp = [1]
    end

    qs = cat.questions.where(:difficulty => diff, :study_path => sp)
    logger.warn PP.pp(qs)
    qs.reject! { |q| !q.complete? }
    qs = qs.sample(cnt)

    json = []
    qs.each do |q|
      @question = q

      hints = []
      q.hints.each do |h|
        @hint = h
        hints << render_to_string(partial: '/hints/render')
      end

      answers = []
      q.answers.each do |a|
        @answer = a
        answers << {
          correct: a.correct,
          correctness: render_to_string(partial: '/answers/render_correctness'),
          id: a.id,
          html: render_to_string(partial: '/answers/render')
        }
      end

      json << {
        'hints' => hints,
        'answers' => answers,
        'matrix' => q.matrix_validate?,
        'matrix_solution' => q.matrix_solution,
        'id' => q.id,
        'html' => render_to_string(partial: '/questions/render')
      }
    end

    render json: json
  end

  def index
    @categories = Category.all
  end

  def new
    @category = Category.new
    @answer = Answer.find(params['parent']) if params['parent']
    @category.answers << @answer if @answer
  end

  def show
    @category = Category.find(params[:id])
  end

  def create
    @category = Category.new(params[:category])
    if @category.save
      flash[:success] = "Kategorie angelegt"
      redirect_to @category
    else
      render 'new'
    end
  end


  def edit
    @category = Category.find(params[:id])
  end

  def update
    @category = Category.find(params[:id])
    if @category.update_attributes(params[:category])
      flash[:success] = "Kategorie aktualisiert"
      redirect_to @category
    else
      render 'edit'
    end
  end


  def destroy
    @category = Category.find(params[:id])
    if @category.destroy
      flash[:success] = "Kategorie gelöscht"
    else
      flash[:error] = "Konnte Kategorie nicht löschen. Details vermutlich in den Logs."
    end
    redirect_to categories_path
  end
end
