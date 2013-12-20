# encoding: utf-8

module JsonHelper
  def json_for_question(q, max_depth = 5)
    qkey = generate_cache_key(q.id)

    cache = cache_check(qkey, Hash)
    return cache if cache

    answers = get_answers(q, max_depth)

    qjson = {
      answers:   answers,
      id:        q.id,
      html:      q.text
    }

    # only include these, if they evaluate to true to save bandwidth
    add_matrix_validate!(qjson, q)
    add_starred!(qjson, q)
    add_hints!(qjson, q)

    # because subquestions are chosen randomly or roulette like, it’s
    # not possible to cache the question if there are subquestions.
    cachable = max_depth > 0 && answers.all? { |a| a[:subquestion].nil? }
    Rails.cache.write(qkey, qjson) if cachable

    qjson
  end

  def get_answers(q, max_depth)
    if max_depth > 0
      ans_qry = Rails.cache.fetch(generate_cache_key(q.id)) {
        # the map forces rails to resolve
        q.answers.includes(:questions, :categories).map { |x| x }
      }
    else
      ans_qry = q.answers
    end
    ans_qry.map { |a| json_for_answer(a, max_depth) }
  end


  def get_subquestion_for_answer(a, max_depth)
    return nil if max_depth <= 0

    qr = QuestionReachability.new(a.get_all_subquestions)
    qr.require_per_params(params)
    sq = qr.get_reachable

    return nil if sq.size == 0

    sq = select_random(sq, 1)
    json_for_question(sq.first, max_depth - 1)
  end


  def json_for_answer(a, max_depth)
    key = generate_cache_key(a.id)

    cache = Rails.cache.read(key)
    return cache if cache

    ajson = {
      correct: a.correct? ? 1 : 0,
      id: a.id,
      html: render_tex(a.text, false)
    }

    subq = get_subquestion_for_answer(a, max_depth)
    ajson[:subqestion] = subq if subq

    cacheable = max_depth > 0 && ajson[:subquestion].nil?
    Rails.cache.write(key, ajson) if cacheable

    ajson
  end

  def add_matrix_validate!(json, q)
    json.merge!({ matrix: 1, matrix_solution: q.matrix_solution }) if q.matrix_validate?
  end

  def add_starred!(json, q)
    json.merge!({ starred: 1 }) if signed_in? && current_user.has_starred?(q)
  end

  def add_hints!(json, q)
    json.merge!({ hints: json_for_hints(q)}) if q.hints.any?
  end

  def json_for_hints(question)
    question.hints.map do |h|
      @hint = h
      render_to_string(partial: '/hints/render')
    end
  end

  def cache_check(key, expected_class)
    cache = Rails.cache.read(key)

    return nil unless cache
    return cache if cache.is_a?(expected_class)

    Rails.cache.delete(key)
    raise "Retrieved cache #{qkey}, received #{cache.class} instead of #{exepected_class}"
  end
end
