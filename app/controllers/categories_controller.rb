# encoding: utf-8

class CategoriesController < ApplicationController
  before_filter :require_admin
  before_filter :def_etag, only: [:index, :index_details, :new, :show, :edit, :activate, :deactivate, :suspicious_associations]

  def index
    @categories = Category.with_questions.select([:id, :title])
    @empty = Category.without_questions
  end

  def index_details
    ids = (params[:category_ids] || "").split(",")
    cats = Category.where(id: ids).includes(:answers, :questions => [:parent]).all
    render partial: "index_details", locals: { cats: cats }
  end

  include DefaultActionsHelper

  def new
    @category = Category.new
    @answer = (Answer.find(params['parent']) rescue nil) if params['parent']
    @category.answers << @answer if @answer
  end

  def show
    @category = Category.find(params[:id])
  end

  def listactivate
    @categories = Category.with_questions.where(released: false).select([:id, :title, :ident])
  end

  def listdeactivate
    @categories = Category.with_questions.where(released: true).select([:id, :title, :ident])
  end

  def activate
    cats = params[:categories].split('_').map(&:to_i)

    ok = true
    @categories = Category.find(cats)
    @categories.each do |cat|
      cat.released = true
      ok = cat.save && ok
      cat.questions.each do |q|
        q.released = true
        ok = q.save && ok
      end
    end
    if ok
      flash[:success] = "Kategorie und alle direkten Unterfragen wurden freigegeben."
    else
      flash[:warning] = "Es sind Fehler aufgetreten. Möglicherweise wurden gar keine oder nur einige Sachen freigegeben."
    end

    render js: %(window.location.href='categories') and return
  end

  def deactivate
    cats = params[:categories].split('_').map(&:to_i)

    ok = true
    @categories = Category.find(cats)
    @categories.each do |cat|
      cat.released = false
      ok = cat.save && ok
      cat.questions.each do |q|
        q.released = false
        ok = q.save && ok
      end
    end
    if ok
      flash[:success] = "Kategorie und alle direkten Unterfragen wurden gesperrt."
    else
      flash[:warning] = "Es sind Fehler aufgetreten. Möglicherweise wurden gar keine oder nur einige Sachen gesperrt."
    end

    render js: %(window.location.href='categories') and return
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
      flash[:success] = "Kategorie und alle direkten Unterfragen wurden freigegeben."
    else
      flash[:warning] = "Es sind Fehler aufgetreten. Möglicherweise wurden gar keine oder nur einige Sachen freigegeben."
    end
    redirect_to @category
  end

  def suspicious_associations
    # fcategories and all associated answers (ignoring subquests)
    root_cats = Category.includes(:questions => [:answers])
    root_cats_answers = {}
    root_cats.each do |rc|
      root_cats_answers[rc] = rc.questions.map { |q| q.answers.map(&:id) }.flatten
    end

    # find categories and their parents (answers). Ignoring root questions
    # because they have no parents by definition.
    other_cats = Category.where(is_root: false).includes(:questions => [:answers])
    other_cats_answers = Hash[other_cats.map { |oc| [oc, oc.answer_ids] }]

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
