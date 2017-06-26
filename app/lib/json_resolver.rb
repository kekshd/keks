# encoding: utf-8

class JsonResolver
  include CacheTools
  @@app_controller = ApplicationController.new

  def self.resolve_efficiently(question_ids, root_count, current_user)
    question_ids.map.with_index do |q, idx|
      # maximum depth of 5 questions. However, avoid going too deep for
      # later questions. For example, the last question never will
      # present a subquestion, regardless if it has one. Therefore, no
      # need to query for them.
      c = root_count - idx - 1
      r = JsonResolver.new(q, [c, 5].min)
      r.current_user = current_user
      tmp = r.resolve

      # assert the generated data looks reasonable, otherwise skip it
      unless tmp.is_a?(Hash)
        raise <<-ERR
          JSON for Question #{q.id} returned an array when it should be a Hash

          #{PP.pp(q, "")}
          ERR
      end

      tmp
    end
  end


  def initialize(question, max_depth = 5)
    @q = question
    @max_depth = max_depth
    @qjson = {}
  end

  def current_user=(user)
    @current_user = user
  end

  def resolve
    cache = cache_check(qkey, Hash)
    return cache if cache

    json_for_question
  end

  def require_per_params(params)
    @params = params
  end

  private

  def json_for_question
    @qjson = {
      answers:   answers,
      id:        @q.id,
      video:     @q.video_link,
      html:      add_newlines(@q.text)
    }

    # only include these, if they evaluate to true to save bandwidth
    add_matrix_validate
    add_starred
    add_hints

    # because subquestions are chosen randomly or roulette like, it’s
    # not possible to cache the question if there are subquestions.
    cachable = @max_depth > 0 && answers.all? { |a| a[:subquestion].nil? }
    Rails.cache.write(qkey, @qjson) if cachable

    @qjson
  end

  def add_matrix_validate
    @qjson.merge!({ matrix: 1, matrix_solution: @q.matrix_solution }) if @q.matrix_validate?
  end

  def add_starred
    @qjson.merge!({ starred: 1 }) if @current_user && @current_user.has_starred?(@q)
  end

  def add_hints
    @qjson.merge!({ hints: json_for_hints }) if @q.hints.any?
  end

  def answers
    return @answers if @answers

    if @max_depth > 0
      ans_qry = Rails.cache.fetch(generate_cache_key(@q.id)) {
        # the map forces rails to resolve
        @q.answers.includes(:questions, :categories).map { |x| x }
      }
    else
      ans_qry = @q.answers
    end

    @answers = ans_qry.map { |a| json_for_answer(a) }
  end

  def json_for_answer(a)
    key = generate_cache_key(a.id)

    cache = Rails.cache.read(key)
    return cache if cache

    ajson = {
      correct: a.correct? ? 1 : 0,
      id: a.id,
      html: add_newlines(a.text)
    }

    subq = get_subquestion_for_answer(a)
    ajson[:subqestion] = subq if subq

    cacheable = @max_depth > 0 && ajson[:subquestion].nil?
    Rails.cache.write(key, ajson) if cacheable

    ajson
  end


  def get_subquestion_for_answer(a)
    return nil if @max_depth <= 0

    qr = QuestionReachability.new(a.get_all_subquestions)
    qr.require_per_params(@params) if @params
    sq = qr.get_reachable

    return nil if sq.size == 0

    sq = sq.sample
    JsonResolver.new(sq, @max_depth - 1).resolve
  end


  def json_for_hints
    @q.hints.map do |h|
      @@app_controller.instance_variable_set("@hint", h)
      @@app_controller.render_to_string(partial: '/hints/render')
    end
  end


  def cache_check(key, expected_class)
    cache = Rails.cache.read(key)

    return nil unless cache
    return cache if cache.is_a?(expected_class)

    Rails.cache.delete(key)
    raise "Retrieved cache #{qkey}, received #{cache.class} instead of #{exepected_class}"
  end

  def qkey
    generate_cache_key(@q.id)
  end

  def add_newlines(content)
    content.gsub(/(\r\n){2,}|\n{2,}|\r{2,}/, '<br/><br/>')
  end
end
