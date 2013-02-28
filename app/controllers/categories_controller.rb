class CategoriesController < ApplicationController
  before_filter :require_admin

  def index
    @categories = Category.all
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(params[:category])
    if @category.save
      flash[:success] = "Kategorie angelegt"
      redirect_to admin_overview_path
    else
      render 'new'
    end
  end
end
