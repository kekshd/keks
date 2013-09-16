# encoding: utf-8

class StatsController < ApplicationController
  before_filter :require_admin, only: :report

  def new
    begin
      quest = Question.find(params[:question_id])
      raise "could not find question" if quest.nil?

      [:question_id, :skipped, :correct].each do |p|
        raise "param #{p} missing" if params[p].nil?
      end

      # if nothing was checked, selected_answers will not be
      # transmitted due to the way array transmission works in HTML
      answers = params[:selected_answers] || []

      skipped = params[:skipped] == "true" ? true : false
      correct = params[:correct] == "true" ? true : false

      if skipped
        answers = []
        correct = false
      end

      # keep valid answers only if in non-matrix mode
      unless quest.matrix_validate?
        answers = answers.map { |a| a.to_i }
        answers.reject! { |a| quest.answers.find(a).nil? }
      end

      user_id = signed_in? ? current_user.id : -1;

      s = Stat.new
      s.question = quest
      s.user_id = user_id
      s.correct = correct
      s.skipped = skipped
      s.selected_answers = answers

      render :json => s.save(:validate => false)
    rescue => e
      logger.warn "Could not save stats: debug output:"
      logger.warn " MSG: #{e.message}"
      logger.warn " QUESTION: #{PP.pp(quest, "")}"
      logger.warn " PARAMS:   #{PP.pp(params, "")}"
      logger.warn " STACKTRACE:   #{PP.pp(e.backtrace, "")}"
      render :json => false
    end
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
      unregistered = Stat.unscoped.where(:user_id => -1, :question_id => questions).where("created_at > ?", 91.days.ago).count


      @keys[key] = {all: all, registered: all - unregistered, unregistered: unregistered}
    end
  end
end
