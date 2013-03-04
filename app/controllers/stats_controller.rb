# encoding: utf-8

class StatsController < ApplicationController
  before_filter :signed_in_user, only: [:edit, :update, :destroy, :enroll, :starred]
  before_filter :correct_user,  only: [:edit, :update, :enroll, :starred]

  def new
    quest = Question.find(params[:question_id]) rescue nil

    # accept skipped answers (-1) as well as all others that exist.
    if params[:answer_id].to_s == "-1"
      answ_id = -1
      correct = false
    else
      answ = quest.answers.find(params[:answer_id]) rescue nil
      correct = answ.correct? rescue false
      answ_id = answ.id rescue nil
    end

    user_id = signed_in? ? current_user.id : -1;
    if quest && answ_id
      s = Stat.new
      s.question = quest
      s.answer_id = answ_id
      s.user_id = user_id
      s.correct = correct

      render :json => s.save(:validate => false)
    else
      render :json => false
    end
  end
end
