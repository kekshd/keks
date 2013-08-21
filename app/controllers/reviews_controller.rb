class ReviewsController < ApplicationController
  before_filter :require_admin_or_reviewer
  before_filter :require_reviewer, only: :save

  before_filter :get_question, only: [:review, :save]

  def messages
    @message = TextStorage.find_or_create_by_ident("review_admin_hints")
  end

  def filter
    f = Review.filter(params[:filter].to_sym)
    @title, @text, @questions = f[:title], f[:text], f[:questions].call(current_user)
  end

  def review
    get_review

  end

  def save
    get_review

    if @review.update_attributes(params[:review])
      flash[:success] = "Review aktualisiert"
      redirect_to question_review_path(@question)
    else
      flash[:error] = "Review konnte nicht gespeichert werden"
      render 'review'
    end
  end


  def get_review
    @review = Review.find_or_initialize_by_user_id_and_question_id(current_user.id, @question.id)
  end


  def get_question
    @question = Question.find(params[:question_id]) if params[:question_id]
    unless @question
      flash[:error] = "Fragen-ID fehlt oder es existiert keine Frage mit dieser ID."
      redirect_to reviews_path
    end
  end


  def need_attention
    @updated = Review.filter(:updated)
    @updated[:questions] = @updated[:questions].call(current_user)

    @need_more_reviews = Review.filter(:need_more_reviews)
    @need_more_reviews[:questions] = @need_more_reviews[:questions].call(current_user)
  end
end
