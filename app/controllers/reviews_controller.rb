# encoding: utf-8

class ReviewsController < ApplicationController
  before_filter :require_admin_or_reviewer
  before_filter :require_reviewer, only: :save

  before_filter :get_question, only: [:review, :save]

  def messages
    @message = TextStorage.find_or_create_by_ident("review_admin_hints")
  end

  def filter
    f = Review.filter(params[:filter])
    @title, @text, @questions = f[:title], f[:text], f[:questions].call(current_user)
    @filter = params[:filter].to_sym
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

    f = Review.filter(pf)
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
    @updated = Review.filter(:updated)
    @updated[:questions] = @updated[:questions].call(current_user)

    @need_more_reviews = Review.filter(:need_more_reviews)
    @need_more_reviews[:questions] = @need_more_reviews[:questions].call(current_user)
  end



  private

  def get_review
    @review = Review.find_or_initialize_by_user_id_and_question_id(current_user.id, @question.id)
  end


  def get_question
    @question = Question.find(params[:question_id]) rescue nil
    unless @question
      flash[:error] = "Fragen-ID fehlt oder es existiert keine Frage mit dieser ID."
      redirect_to reviews_path
    end
  end
end
