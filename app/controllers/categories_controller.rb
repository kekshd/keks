# encoding: utf-8

class CategoriesController < ApplicationController
  before_filter :require_admin

  def index
    @categories = Category.all
  end

  def new
    @category = Category.new
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
end
