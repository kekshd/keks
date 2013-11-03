# encoding: utf-8

class StatsController < ApplicationController
  before_filter :require_admin, except: :new
  before_filter :get_question, only: :new

  def new
    [:question_id, :skipped, :correct, :time_taken].each do |p|
      return render(text: "param #{p} missing") if params[p].nil?
    end

    # if nothing was checked, selected_answers will not be
    # transmitted due to the way array transmission works in HTML
    answers = params[:selected_answers] || []
    skipped = params[:skipped] == "true"
    correct = params[:correct] == "true"

    if skipped
      answers = []
      correct = false
    end

    # keep valid answers only if in non-matrix mode
    unless @question.matrix_validate?
      answers = answers.map(&:to_i) & @question.answers.pluck(:id)
    end

    status = Stat.new(
      question_id: @question.id,
      user_id: current_user_id,
      correct: correct,
      skipped: skipped,
      time_taken: params[:time_taken].to_i,
      selected_answers: answers
      ).save

    render json: status
  end

  include StatsHelper
  def report
    @key = params[:enrollment_key]
    return redirect_to admin_overview_path unless EnrollmentKeys.names.include?(@key)

    @users = User.find(:all, :conditions => ["enrollment_keys LIKE ?", "%#{@key}%"])
    @last_stats = Stat.unscoped.where(:user_id => @users.map { |u| u.id }).where("created_at > ?", 91.days.ago)

    qstats = {}
    time = Time.now

    #~　@last_stats.each do |stat|
      #~　next unless stat.question
      #~　qid = stat.question_id
      #~　qstats[qid] ||= { right: [0]*13, wrong: [0]*13, skipped: [0]*13}
      #~　insert_stat_in_hash(stat, qstats[qid], time)
    #~　end

    #~　@h = render_graph
    #~　qstats.each do |qid, data|
      #~　percent_correct, percent_skipped = raw_to_percentage(data)
      #~　@h.series(:name=> Question.find(qid).ident, :data => percent_correct)
    #~　end

    @questions = @users.map { |u| u.seen_questions }.flatten.uniq
  end

  def category_report
    @range = [(params[:range] || "91" ).to_i, 1].max

    groups = {}

    Category.all.each do |c|
      next unless c.is_root?
      root = c.title.split(":")[0]
      groups[root] ||= []
      groups[root] += c.questions.map { |q| q.id }
    end

    @keys = {}
    groups.each do |key, questions|
      next if questions.empty?

      all = Stat.unscoped.where(:question_id => questions).where("created_at > ?", @range.days.ago).count
      unregistered = Stat.unscoped.where(:user_id => -1, :question_id => questions).where("created_at > ?", @range.days.ago).count


      @keys[key] = {all: all, registered: all - unregistered, unregistered: unregistered}
    end
  end

  def activity_report
    max_days_ago = DateTime.now.mjd - DateTime.parse("2013-02-17").mjd
    @range = [[(params[:range] || 91 ).to_i, 1].max, max_days_ago].min

    stats = Stat.unscoped.where("created_at > ?", @range.days.ago)
    quests = stats.group("date(created_at)").count

    users_inner = stats.group('user_id, date(created_at)').select("date(created_at) AS date").to_sql
    users_outer = "SELECT date, COUNT(*) FROM (#{users_inner}) GROUP BY date"
    users = Hash[ActiveRecord::Base.connection.select_rows(users_outer)]

    @g_quests = render_date_to_count_graph('beantwortete Fragen', quests,  @range)
    @g_users  = render_date_to_count_graph('aktive Nutzer',       users,   @range)
  end
end
