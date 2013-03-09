# encoding: utf-8

class StatsController < ApplicationController
  before_filter :require_admin, only: :report

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

  include StatsHelper
  def report
    @key = params[:enrollment_key]
    return redirect_to admin_overview_path unless EnrollmentKeys.names.include?(@key)

    @users = User.find(:all, :conditions => ["enrollment_keys LIKE ?", "%#{@key}%"])
    @last_stats = @users.map { |u| u.stats.unscoped.where("created_at > ?", 91.days.ago) }.flatten

    qstats = {}
    time = Time.now

    @last_stats.each do |stat|
      qid = stat.question_id
      qstats[qid] ||= { right: [0]*13, wrong: [0]*13, skipped: [0]*13}
      insert_stat_in_hash(stat, qstats[qid], time)
    end

    @h = render_graph
    qstats.each do |qid, data|
      percent_correct, percent_skipped = raw_to_percentage(data)
      @h.series(:name=> Question.find(qid).ident, :data => percent_correct)
    end

    @questions = @users.map { |u| u.seen_questions }.flatten.uniq
  end
end
