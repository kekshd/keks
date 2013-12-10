# encoding: utf-8

class ReviewsController < ApplicationController
  before_filter :require_admin_or_reviewer
  before_filter :require_reviewer, only: :save

  before_filter only: [:review, :save] do get_question(reviews_path) end

  def messages
    @message = TextStorage.find_or_create_by_ident("review_admin_hints")
  end

  def filter
    f = Review.filter(params[:filter])
    @title, @text, @questions = f[:title], f[:text], f[:questions].call(current_user)
    @filter = params[:filter]
  end

  def review
    get_review

  end

  def save
    get_review

    if @review.update_attributes(params[:review])
      flash[:success] = "Review aktualisiert"
      redirect_to question_review_path(@question, filter: params[:filter], next: params[:next])
    else
      flash[:error] = "Review konnte nicht gespeichert werden"
      render 'review'
    end
  end

  def find_next
    pf = params[:filter]
    begin
      f = Review.filter(pf)
    rescue => e # most likely filter doesn’t exist
      flash[:warning] = e.message
      return redirect_to reviews_path
    end


    qqs = f[:questions].call(current_user)
    qqs_ids = qqs.map { |q| q.id.to_s }

    next_list = (params[:next] || "").split(",")

    if qqs.none?
      flash[:notice] = "Keine Reviews mehr nötig bzgl. Filter „#{pf}“"
      return redirect_to reviews_path
    end

    while next_list.any?
      x = next_list.shift
      next unless qqs_ids.include?(x)
      return redirect_to question_review_path(x, filter: pf, next: next_list.join(','))
    end

    flash[:notice] = "Keine Einträge (mehr) in der Review Reihenfolge. Wähle zufälligen Eintrag aus „#{pf}“"
    return redirect_to question_review_path(qqs.sample(1), filter: pf)
  end

  def need_attention
    # admins do not get any lists with questions to review, so no need
    # to calculate those.
    if reviewer?
      @updated = Review.filter(:updated)
      @updated[:questions] = @updated[:questions].call(current_user)

      @need_more_reviews = Review.filter(:need_more_reviews)
      @need_more_reviews[:questions] = @need_more_reviews[:questions].call(current_user)
    end
  end



  private

  def get_review
    @review = Review.find_or_initialize_by_user_id_and_question_id(current_user.id, @question.id)
  end
end
