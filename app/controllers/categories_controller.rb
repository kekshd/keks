# encoding: utf-8

class CategoriesController < ApplicationController
  before_filter :require_admin

  def index
    @categories = Category.includes(:questions => [:answers, :reviews]).all
  end

  def new
    @category = Category.new
    @answer = (Answer.find(params['parent']) rescue nil) if params['parent']
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

  def release
    ok = true
    @category = Category.find(params[:id])
    @category.released = true
    ok = @category.save && ok
    @category.questions.each do |q|
      q.released = true
      ok = q.save && ok
    end
    if ok
      flash[:success] = "Kategorie und alle direkten Unterfragen wurden freigegeben"
    else
      flash[:warning] = "Es sind Fehler aufgetreten. Möglicherweise wurden gar keine oder nur einige Sachen freigegeben."
    end
    redirect_to @category
  end


  def edit
    @category = Category.find(params[:id]) rescue nil
    unless @category
      flash[:warning] = "Diese Kategorie gibt es nicht. Wurde sie zwischenzeitlich evtl. gelöscht?"
      return redirect_to categories_path
    end
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

  def suspicious_associations
    # fcategories and all associated answers (ignoring subquests)
    root_cats =  Category.includes(:questions => [:answers])
    root_cats_answers = {}
    root_cats.each do |rc|
      root_cats_answers[rc] =  rc.questions.map { |q| q.answers.map { |a| a.id } }.flatten
    end

    # find categories and their parents (answers). Ignoring root questions
    # because they have no parents by definition.
    other_cats = Category.where(is_root: false).includes(:questions => [:answers])
    other_cats_answers = {}
    other_cats.each do |oc|
      other_cats_answers[oc] = oc.answer_ids
    end

    # compare against each other to see if any non-root category selects
    # almost all answers of a root category. This makes it obvious if
    # this category should be child to a whole other category.
    @suspicious = []
    other_cats_answers.each do |oc, sel_answ|
      root_cats_answers.each do |rc, avail_answ|
        next if avail_answ.none? || oc == rc
        remain = avail_answ - sel_answ
        ratio = 1.0 - remain.size.to_f / avail_answ.size.to_f
        next if ratio  < 0.7 || ratio == 1.0
        @suspicious << {child: oc, parent: rc, ratio: ratio}
      end
    end
  end
end
