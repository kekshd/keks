class ReviewsController < ApplicationController
  before_filter :require_admin_or_reviewer
  before_filter :require_reviewer, only: :save

  before_filter :get_question, only: [:review, :save]

  def overview
    @reviews = Review.where(user_id: current_user)
    @reviews_need_update = @reviews.select { |r| r.question_updated_since? }
    reviewed_question_ids = @reviews.map { |r| r.question_id }

    @questions = Question.includes(:reviews).all
    @questions_need_review = @questions.select do |q|
      q.reviews.size < REVIEW_MIN_REQUIRED_REVIEWS \
        and !reviewed_question_ids.include?(q.id)
    end
  end

  def not_okay
    @questions = Review.where(okay: false).map { |r| r.question }.uniq
  end

  def no_reviews
    @questions = Question.includes(:reviews).reject! { |q| q.reviews.any? }
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

  private
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
end
