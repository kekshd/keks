# encoding: utf-8

class StatsController < ApplicationController
  before_filter :require_admin, except: :new
  before_filter :get_question, only: :new
  before_filter :extract_range_from_params, only: [:category_report, :activity_report]

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

  before_filter :require_valid_enrollment_key, only: :report
  def report
    @key = params[:enrollment_key]
    @users = User.enrolled_in(@key)
    @last_stats = Stat.where(user_id: @users.pluck(:id)).newer_than(91.days.ago)
    @questions = @users.map(&:seen_questions).flatten.uniq
  end

  def category_report
    groups = {}

    Category.is_root.with_questions.each do |c|
      t = c.title_split.reject { |t| t.blank? }.first
      groups[t] ||= []
      groups[t] += c.questions.pluck(:id)
    end

    @keys = {}
    groups.each do |key, questions|
      all, unregistered = *[Stat, Stat.anonymous].map do |s|
        s.where(question_id: questions).newer_than(@range.days.ago).count
      end

      @keys[key] = {all: all, registered: all - unregistered, unregistered: unregistered, questions: questions}
    end
  end

  def activity_report
    extract_questions_from_params

    key = "activity_report__#{@range}__#{(@questions || []).join("_")}"

    cache = Rails.cache.fetch(key)
    return (@g_quests, @g_users = *cache) if cache

    stats = Stat.unscoped.newer_than(@range.days.ago)
    stats = stats.where(question_id: @questions) if @questions

    quests = stats.group("date(created_at)").count

    users_inner = stats.group('user_id, date(created_at)').select("date(created_at) AS date").to_sql
    users_outer = "SELECT date, COUNT(*) FROM (#{users_inner}) as users_inner GROUP BY date"
    users = Hash[ActiveRecord::Base.connection.select_rows(users_outer)]

    @g_quests = render_date_to_count_graph('beantwortete Fragen', quests,  @range)
    @g_users  = render_date_to_count_graph('aktive Nutzer',       users,   @range)

    Rails.cache.write(key, [@g_quests, @g_users], expires_in: 24.hours)
  end

  private

  def extract_range_from_params
    max_days_ago = DateTime.now.mjd - DateTime.parse("2013-02-17").mjd
    @range = [[(params[:range] || 91 ).to_i, 1].max, max_days_ago].min
  end

  def extract_questions_from_params
    @questions = params[:questions].split("_").map(&:to_i).uniq.sort rescue []
    @questions = nil if @questions.empty? || @questions.all? { |id| id == 0 }
  end
end
