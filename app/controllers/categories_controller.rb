# encoding: utf-8

class CategoriesController < ApplicationController
  before_filter :require_admin, :except => :questions

  def questions
    cat = Category.find(params[:id])

    cnt = params[:count].to_i
    return render :json => {error: "No count given"} if cnt <= 0 || cnt >= 100

    diff = difficulties_from_param
    sp = study_path_ids_from_param

    qs = cat.questions.where(:difficulty => diff, :study_path => sp)
    qs.reject! { |q| !q.complete? }
    if signed_in?
      # select questions depending on how often they were answered
      # correctly.
      qs = roulette(qs, current_user, cnt)
    else
      # uniform distrubtion
      qs = qs.sample(cnt)
    end

    json = []
    json = qs.map { |q| json_for_question(q) }

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
